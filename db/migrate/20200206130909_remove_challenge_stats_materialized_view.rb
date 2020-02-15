class RemoveChallengeStatsMaterializedView < ActiveRecord::Migration[5.2]
  def change
    drop_view :challenge_stats
  end
end
