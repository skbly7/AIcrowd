class AddTeamFreezeTimeToChallenges < ActiveRecord::Migration[5.2]
  def change
    add_column :challenges, :team_freeze_time, :datetime
  end
end
