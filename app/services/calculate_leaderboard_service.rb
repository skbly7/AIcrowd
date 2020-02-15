class CalculateLeaderboardService
  def initialize(challenge_round_id:)
    @round = ChallengeRound.find(challenge_round_id)
    @conn  = ActiveRecord::Base.connection
  end

  def call
    start_time = Time.zone.now
    if @round.submissions.blank?
      purge_leaderboard
    else
      ActiveRecord::Base.transaction do
        truncate_scores
        purge_leaderboard
        init_temp_submission_stats
        create_leaderboard(leaderboard_type: 'leaderboard')
        create_leaderboard(leaderboard_type: 'ongoing')
        create_leaderboard(leaderboard_type: 'previous')
        create_leaderboard(leaderboard_type: 'previous_ongoing')
        destroy_temp_submission_stats
        update_leaderboard_rankings(
          leaderboard: 'leaderboard',
          prev:        'previous')
        update_leaderboard_rankings(
          leaderboard: 'ongoing',
          prev:        'previous_ongoing')
        insert_baseline_rows(leaderboard_type: 'leaderboard')
        insert_baseline_rows(leaderboard_type: 'ongoing')
        set_leaderboard_sequences(leaderboard_type: 'leaderboard')
        set_leaderboard_sequences(leaderboard_type: 'ongoing')
      end
    end
    now = Time.zone.now
    Rails.logger.info "Calculated leaderboard for round #{@round.id} in #{format('%0.3f', (now - start_time).to_f)}s."
    true
  end

  def truncate_scores
    @conn.execute <<~SQL
      UPDATE submissions
      SET
        score_display = ROUND(score::numeric,#{@round.score_precision}),
        score_secondary_display = ROUND(score_secondary::numeric,#{@round.score_secondary_precision})
      WHERE challenge_round_id = #{@round.id}
    SQL
  end

  def window_border_dttm
    most_recent = Submission
                      .where(challenge_round_id: @round.id)
                      .order(created_at: :desc)
                      .limit(1)
                      .first
    window_border = most_recent.created_at - @round.ranking_window.hours
    return "'#{window_border.to_s(:db)}'"
  end

  def purge_leaderboard
    @conn.execute <<~SQL
      DELETE
      FROM base_leaderboards
      WHERE challenge_round_id = #{@round.id};
    SQL
  end

  def leaderboard_params(leaderboard_type:)
    case leaderboard_type
    when 'leaderboard'
      post_challenge = '(FALSE)'
      cuttoff_dttm   = 'current_timestamp'
    when 'ongoing'
      post_challenge = '(TRUE,FALSE)'
      cuttoff_dttm   = 'current_timestamp'
    when 'previous'
      post_challenge = '(FALSE)'
      cuttoff_dttm   = window_border_dttm
    when 'previous_ongoing'
      post_challenge = '(TRUE,FALSE)'
      cuttoff_dttm   = window_border_dttm
    end
    return [post_challenge, cuttoff_dttm]
  end

  def init_temp_submission_stats
    @conn.execute <<~SQL
      CREATE TEMPORARY TABLE temp_submission_stats (
        submission_id INT UNIQUE,
        submitter_type VARCHAR,
        submitter_id INT,
        submitter_entries_cnt INT,
        submission_rank INT
      );
      CREATE INDEX ON temp_submission_stats (submitter_type, submitter_id);
      CREATE INDEX ON temp_submission_stats (submission_rank);
    SQL
  end

  def destroy_temp_submission_stats
    @conn.execute <<~SQL
      DROP TABLE temp_submission_stats;
    SQL
  end

  def reset_temp_submission_stats(leaderboard_type:)
    post_challenge, cuttoff_dttm = leaderboard_params(leaderboard_type: leaderboard_type)

    # clear any previous temp data
    @conn.execute <<~SQL
      DELETE
      FROM temp_submission_stats;
    SQL

    # Select only those Team Participants that are related to this challenge.
    relevant_team_participants = <<~SQL
      SELECT * FROM team_participants tp INNER JOIN teams t ON tp.team_id = t.id where t.challenge_id = #{@round.challenge.id}
    SQL

    relevant_old_participants = <<~SQL
      SELECT *
        FROM migration_mappings mm INNER JOIN submissions s ON mm.source_id = s.id
        WHERE mm.source_type='Submission' AND s.challenge_round_id = #{@round.id} AND s.created_at <= #{cuttoff_dttm}
        AND s.baseline IS FALSE
    SQL

    # associate relevant submissions with their submitter
    @conn.execute <<~SQL
      INSERT INTO temp_submission_stats
      SELECT
        s.id AS submission_id,
        CASE WHEN tp.team_id IS NULL THEN 'Participant' ELSE 'Team'     END AS submitter_type,
        CASE WHEN tp.team_id IS NULL THEN p.id          ELSE tp.team_id END AS submitter_id
      FROM submissions s
      INNER JOIN participants p ON p.id = s.participant_id
      LEFT JOIN (#{relevant_team_participants}) tp ON p.id = tp.participant_id
      WHERE
        s.challenge_round_id = #{@round.id}
        AND s.post_challenge IN #{post_challenge}
        AND s.created_at <= #{cuttoff_dttm}
        AND s.baseline IS FALSE
      ORDER BY submission_id;
    SQL

    # Below we add OldParticipant records to the temp table to enable
    # Calculation of leaderboard for unknown participants
    # Once a user has migrated we still have old MigrationMapping records that we dont
    # need to use, and there will be conflict with them already added above, thus the ON CONFLICT DO NOTHING is used
    @conn.execute <<~SQL
      INSERT INTO temp_submission_stats
      SELECT mm.source_id, 'OldParticipant', mm.crowdai_participant_id
      FROM (#{relevant_old_participants}) mm
      ORDER BY mm.source_id
      ON CONFLICT DO NOTHING;
    SQL

    # record number of entries for each submitter
    entry_counter_query = <<~SQL
      SELECT
        stats.submitter_type,
        stats.submitter_id,
        COUNT(stats.*) as entries_cnt
      FROM temp_submission_stats stats
      GROUP BY
        submitter_type,
        submitter_id
    SQL
    @conn.execute <<~SQL
      UPDATE temp_submission_stats stats
      SET submitter_entries_cnt = q.entries_cnt
      FROM (#{entry_counter_query}) q
      WHERE
        stats.submitter_type = q.submitter_type
        AND stats.submitter_id = q.submitter_id;
    SQL

    # rank the graded submissions, by submitter
    rank_retrieval_query = <<~SQL
      SELECT
        stats.submission_id,
        ROW_NUMBER() OVER (
          PARTITION BY
            stats.submitter_type,
            stats.submitter_id
          ORDER BY s.#{order_by(use_display: true)}
        ) AS rank
      FROM submissions s
      INNER JOIN temp_submission_stats stats ON s.id = stats.submission_id
      WHERE s.grading_status_cd = 'graded'
    SQL
    @conn.execute <<~SQL
      UPDATE temp_submission_stats stats
      SET submission_rank = q.rank
      FROM (#{rank_retrieval_query}) q
      WHERE stats.submission_id = q.submission_id;
    SQL
  end

  def create_leaderboard(leaderboard_type:)
    # use temporary table to store stats that would require complex logic and redundant subqueries
    # already filtered to submissions pertaining to this round
    reset_temp_submission_stats(leaderboard_type: leaderboard_type)

    # store the relevant data from each of the relevant submissions, but only the best one per submitter
    @conn.execute <<~SQL
      INSERT INTO base_leaderboards (
        id,
        challenge_id,
        challenge_round_id,
        submitter_type,
        submitter_id,
        submission_id,
        seq,
        row_num,
        previous_row_num,
        entries,
        score,
        score_secondary,
        meta,
        media_large,
        media_thumbnail,
        media_content_type,
        description,
        description_markdown,
        leaderboard_type_cd,
        post_challenge,
        refreshed_at,
        created_at,
        updated_at
      )
      SELECT
        nextval('base_leaderboards_id_seq'::regclass),
        #{@round.challenge_id},
        #{@round.id},
        stats.submitter_type,
        stats.submitter_id,
        s.id,
        0 as SEQ,
        ROW_NUMBER() OVER (ORDER BY s.#{order_by(use_display: true)}) AS ROW_NUM,
        0 as PREVIOUS_ROW_NUM,
        stats.submitter_entries_cnt,
        s.score_display,
        s.score_secondary_display,
        s.meta,
        s.media_large,
        s.media_thumbnail,
        s.media_content_type,
        s.description,
        s.description_markdown,
        '#{leaderboard_type}',
        s.post_challenge,
        '#{DateTime.now.to_s(:db)}',
        s.created_at,
        s.updated_at
      FROM submissions s
      INNER JOIN temp_submission_stats stats ON s.id = stats.submission_id
      WHERE stats.submission_rank = 1;
    SQL
  end

  def update_leaderboard_rankings(leaderboard:, prev:)
    @conn.execute <<~SQL
      WITH lb AS (
        SELECT l.row_num,
               p.row_num AS prev_row_num,
               l.challenge_id,
               l.challenge_round_id,
               l.submitter_type,
               l.submitter_id
        FROM base_leaderboards l,
             base_leaderboards p
        WHERE l.challenge_id = p.challenge_id
        AND l.challenge_round_id = p.challenge_round_id
        AND l.challenge_round_id = #{@round.id}
        AND l.submitter_type = p.submitter_type
        AND l.submitter_id = p.submitter_id
        AND l.leaderboard_type_cd = '#{leaderboard}'
        AND p.leaderboard_type_cd = '#{prev}')
      UPDATE base_leaderboards
      SET previous_row_num = lb.prev_row_num
      FROM lb
      WHERE base_leaderboards.leaderboard_type_cd = '#{leaderboard}'
      AND base_leaderboards.challenge_round_id = lb.challenge_round_id
      AND base_leaderboards.challenge_round_id = #{@round.id}
      AND base_leaderboards.submitter_type = lb.submitter_type
      AND base_leaderboards.submitter_id = lb.submitter_id
    SQL
  end

  def insert_baseline_rows(leaderboard_type:)
    post_challenge, cuttoff_dttm = leaderboard_params(leaderboard_type: leaderboard_type)
    @conn.execute <<~SQL
      INSERT INTO base_leaderboards (
        id,
        challenge_id,
        challenge_round_id,
        submitter_type,
        submitter_id,
        submission_id,
        seq,
        row_num,
        previous_row_num,
        entries,
        score,
        score_secondary,
        meta,
        media_large,
        media_thumbnail,
        media_content_type,
        description,
        description_markdown,
        leaderboard_type_cd,
        post_challenge,
        baseline,
        baseline_comment,
        refreshed_at,
        created_at,
        updated_at
      )
      SELECT
        nextval('base_leaderboards_id_seq'::regclass),
        s.challenge_id,
        s.challenge_round_id,
        'Participant',
        s.participant_id,
        s.id as submission_id,
        0 as seq,
        0 as row_num,
        0 as previous_row_num,
        0 as entries,
        s.score,
        s.score_secondary,
        s.meta,
        s.media_large,
        s.media_thumbnail,
        s.media_content_type,
        s.description,
        s.description_markdown,
        '#{leaderboard_type}',
        s.post_challenge,
        s.baseline,
        s.baseline_comment,
        '#{DateTime.now.to_s(:db)}',
        s.created_at,
        s.updated_at
      FROM submissions s
      WHERE s.challenge_round_id = #{@round.id}
      AND s.grading_status_cd = 'graded'
      AND s.post_challenge IN #{post_challenge}
      AND s.created_at <= #{cuttoff_dttm}
      AND s.baseline IS TRUE
    SQL
  end

  def set_leaderboard_sequences(leaderboard_type:)
    post_challenge, cuttoff_dttm = leaderboard_params(leaderboard_type: leaderboard_type)

    @conn.execute <<~SQL
        WITH lb AS (
        SELECT
          l.id,
          l.submission_id,
          l.row_num,
          ROW_NUMBER() OVER (
            PARTITION by l.challenge_id,
                         l.challenge_round_id,
                         l.leaderboard_type_cd
            ORDER BY #{order_by}, l.row_num asc) AS SEQ
        FROM base_leaderboards l
        WHERE l.challenge_round_id = #{@round.id})
      UPDATE base_leaderboards
      SET seq = lb.seq
      FROM lb
      WHERE base_leaderboards.id = lb.id
    SQL
  end

  def sort_map(sort_field)
    case sort_field
    when 'ascending'
      return 'asc'
    when 'descending'
      return 'desc'
    else
      return nil
    end
  end

  def order_by(use_display: false)
    challenge = @round.challenge

    return 'updated_at desc' if challenge.latest_submission == true

    score_sort_order ||= sort_map(@round.primary_sort_order_cd)
    score_sort_col     = use_display ? 'score_display' : 'score'

    return "#{score_sort_col} #{score_sort_order} NULLS LAST" if @round.secondary_sort_order_cd.blank? || @round.secondary_sort_order_cd == 'not_used'

    secondary_sort_order ||= sort_map(@round.secondary_sort_order_cd)
    secondary_sort_col     = use_display ? 'score_secondary_display' : 'score_secondary'
    "#{score_sort_col} #{score_sort_order} NULLS LAST, #{secondary_sort_col} #{secondary_sort_order} NULLS LAST"
  end
end
