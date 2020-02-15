class RemoveCrowdaiFromChallengeCalls < ActiveRecord::Migration[5.2]
  def change
    remove_column :challenge_calls, :crowdai, :boolean
  end
end
