class RemoveLoginActivitiesTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :login_activities
  end
end
