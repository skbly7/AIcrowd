class AddOtherScoresFieldnamesToChallenges < ActiveRecord::Migration[5.2]
  def change
    add_column :challenges, :other_scores_fieldnames, :string
  end
end
