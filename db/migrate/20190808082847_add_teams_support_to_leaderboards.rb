class AddTeamsSupportToLeaderboards < ActiveRecord::Migration[5.2]
  def up
    drop_leaderboard_views
    change_table :base_leaderboards do |t|
      t.references :submitter, polymorphic: true
    end
    execute <<~SQL
      UPDATE base_leaderboards
      SET
        submitter_type = 'Participant',
        submitter_id = participant_id
      WHERE participant_id IS NOT NULL
    SQL
    change_table :base_leaderboards do |t|
      t.remove_references :participant
    end
    create_leaderboard_views(:submitter_type, :submitter_id)
  end

  def down
    drop_leaderboard_views
    change_table :base_leaderboards do |t|
      t.references :participant, foreign_key: true
    end
    execute <<~SQL
      UPDATE base_leaderboards
      SET
        participant_id = submitter_id
      WHERE submitter_type = 'Participant'
    SQL
    change_table :base_leaderboards do |t|
      t.remove_references :submitter, polymorphic: true
    end
    create_leaderboard_views(:participant_id)
  end

  private def drop_leaderboard_views
    execute <<~SQL
      DROP VIEW IF EXISTS leaderboards;
      DROP VIEW IF EXISTS ongoing_leaderboards;
      DROP VIEW IF EXISTS previous_leaderboards;
      DROP VIEW IF EXISTS previous_ongoing_leaderboards;
    SQL
  end

  private def create_leaderboard_views(*submitter_columns)
    submitter_select = submitter_columns.map do |col|
      "base_leaderboards.#{col}"
    end.join(', ')
    create_view 'leaderboards',  sql_definition: <<~SQL
      SELECT
        base_leaderboards.id,
        base_leaderboards.challenge_id,
        base_leaderboards.challenge_round_id,
        #{submitter_select},
        base_leaderboards.row_num,
        base_leaderboards.previous_row_num,
        base_leaderboards.slug,
        base_leaderboards.name,
        base_leaderboards.entries,
        base_leaderboards.score,
        base_leaderboards.score_secondary,
        base_leaderboards.meta,
        base_leaderboards.media_large,
        base_leaderboards.media_thumbnail,
        base_leaderboards.media_content_type,
        base_leaderboards.description,
        base_leaderboards.description_markdown,
        base_leaderboards.leaderboard_type_cd,
        base_leaderboards.refreshed_at,
        base_leaderboards.created_at,
        base_leaderboards.updated_at,
        base_leaderboards.submission_id,
        base_leaderboards.post_challenge,
        base_leaderboards.seq,
        base_leaderboards.baseline,
        base_leaderboards.baseline_comment
      FROM base_leaderboards
      WHERE base_leaderboards.leaderboard_type_cd::text = 'leaderboard'::text;
    SQL
    create_view 'ongoing_leaderboards',  sql_definition: <<~SQL
      SELECT
        base_leaderboards.id,
        base_leaderboards.challenge_id,
        base_leaderboards.challenge_round_id,
        #{submitter_select},
        base_leaderboards.row_num,
        base_leaderboards.previous_row_num,
        base_leaderboards.slug,
        base_leaderboards.name,
        base_leaderboards.entries,
        base_leaderboards.score,
        base_leaderboards.score_secondary,
        base_leaderboards.meta,
        base_leaderboards.media_large,
        base_leaderboards.media_thumbnail,
        base_leaderboards.media_content_type,
        base_leaderboards.description,
        base_leaderboards.description_markdown,
        base_leaderboards.leaderboard_type_cd,
        base_leaderboards.refreshed_at,
        base_leaderboards.created_at,
        base_leaderboards.updated_at,
        base_leaderboards.submission_id,
        base_leaderboards.post_challenge,
        base_leaderboards.seq,
        base_leaderboards.baseline,
        base_leaderboards.baseline_comment
      FROM base_leaderboards
      WHERE base_leaderboards.leaderboard_type_cd::text = 'ongoing'::text;
    SQL
    create_view 'previous_leaderboards',  sql_definition: <<~SQL
      SELECT
        base_leaderboards.id,
        base_leaderboards.challenge_id,
        base_leaderboards.challenge_round_id,
        #{submitter_select},
        base_leaderboards.row_num,
        base_leaderboards.previous_row_num,
        base_leaderboards.slug,
        base_leaderboards.name,
        base_leaderboards.entries,
        base_leaderboards.score,
        base_leaderboards.score_secondary,
        base_leaderboards.media_large,
        base_leaderboards.media_thumbnail,
        base_leaderboards.media_content_type,
        base_leaderboards.description,
        base_leaderboards.description_markdown,
        base_leaderboards.leaderboard_type_cd,
        base_leaderboards.refreshed_at,
        base_leaderboards.created_at,
        base_leaderboards.updated_at,
        base_leaderboards.submission_id,
        base_leaderboards.post_challenge,
        base_leaderboards.seq,
        base_leaderboards.baseline,
        base_leaderboards.baseline_comment
      FROM base_leaderboards
      WHERE base_leaderboards.leaderboard_type_cd::text = 'previous'::text;
    SQL
    create_view 'previous_ongoing_leaderboards',  sql_definition: <<~SQL
      SELECT
        base_leaderboards.id,
        base_leaderboards.challenge_id,
        base_leaderboards.challenge_round_id,
        #{submitter_select},
        base_leaderboards.row_num,
        base_leaderboards.previous_row_num,
        base_leaderboards.slug,
        base_leaderboards.name,
        base_leaderboards.entries,
        base_leaderboards.score,
        base_leaderboards.score_secondary,
        base_leaderboards.media_large,
        base_leaderboards.media_thumbnail,
        base_leaderboards.media_content_type,
        base_leaderboards.description,
        base_leaderboards.description_markdown,
        base_leaderboards.leaderboard_type_cd,
        base_leaderboards.refreshed_at,
        base_leaderboards.created_at,
        base_leaderboards.updated_at,
        base_leaderboards.submission_id,
        base_leaderboards.post_challenge,
        base_leaderboards.seq,
        base_leaderboards.baseline,
        base_leaderboards.baseline_comment
      FROM base_leaderboards
      WHERE base_leaderboards.leaderboard_type_cd::text = 'previous_ongoing'::text;
    SQL
  end
end
