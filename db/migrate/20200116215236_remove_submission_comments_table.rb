class RemoveSubmissionCommentsTable < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :submission_comments, :participants
    remove_foreign_key :submission_comments, :submissions

    drop_table :submission_comments
  end
end
