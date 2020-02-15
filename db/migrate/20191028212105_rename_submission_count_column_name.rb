class RenameSubmissionCountColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :challenges, :submission_count, :submissions_count
  end
end
