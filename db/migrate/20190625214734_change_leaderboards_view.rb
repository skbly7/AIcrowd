class ChangeLeaderboardsView < ActiveRecord::Migration[5.2]

      execute <<-SQL
          drop view if exists "leaderboards";
          drop view if exists "ongoing_leaderboards";
      SQL

      create_view "leaderboards",  sql_definition: <<-SQL
          SELECT base_leaderboards.id,
          base_leaderboards.challenge_id,
          base_leaderboards.challenge_round_id,
          base_leaderboards.participant_id,
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
        WHERE ((base_leaderboards.leaderboard_type_cd)::text = 'leaderboard'::text);
      SQL

      create_view "ongoing_leaderboards",  sql_definition: <<-SQL
          SELECT base_leaderboards.id,
          base_leaderboards.challenge_id,
          base_leaderboards.challenge_round_id,
          base_leaderboards.participant_id,
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
        WHERE ((base_leaderboards.leaderboard_type_cd)::text = 'ongoing'::text);
      SQL
end
