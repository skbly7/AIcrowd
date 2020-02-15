class CreateChallengeStatsMaterializedView < ActiveRecord::Migration[5.2]
  def change
    create_view :challenge_stats, version: 1
  end
end
