class AddMetaToBaseLeaderboards < ActiveRecord::Migration[5.2]
  def change
    add_column :base_leaderboards, :meta, :json
  end
end
