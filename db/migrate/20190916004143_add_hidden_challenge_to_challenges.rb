class AddHiddenChallengeToChallenges < ActiveRecord::Migration[5.2]
  def change
    change_table :challenges do |t|
      t.boolean :hidden_challenge, default: false, null: false
    end
  end
end
