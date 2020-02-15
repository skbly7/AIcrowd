class RemoveCommentsTable < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :comments, :participants
    remove_foreign_key :comments, :topics

    drop_table :comments
  end
end
