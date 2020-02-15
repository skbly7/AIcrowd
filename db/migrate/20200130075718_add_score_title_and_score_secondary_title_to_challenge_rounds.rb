class AddScoreTitleAndScoreSecondaryTitleToChallengeRounds < ActiveRecord::Migration[5.2]
  def change
    add_column :challenge_rounds, :score_title, :string, null: false, default: ''
    add_column :challenge_rounds, :score_secondary_title, :string, null: false, default: ''
  end
end
