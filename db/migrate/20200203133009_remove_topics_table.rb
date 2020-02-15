class RemoveTopicsTable < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :topics, :challenges
    remove_foreign_key :topics, :participants

    drop_table :topics
  end
end
