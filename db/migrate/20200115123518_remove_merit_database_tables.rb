class RemoveMeritDatabaseTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :merit_actions
    drop_table :merit_activity_logs
    drop_table :merit_score_points
    drop_table :merit_scores
    drop_table :sashes
    drop_table :badges_sashes

    remove_column :participants, :sash_id
    remove_column :participants, :level
  end
end
