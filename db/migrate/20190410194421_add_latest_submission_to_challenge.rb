class AddLatestSubmissionToChallenge < ActiveRecord::Migration[5.2]
  def change
    add_column :challenges, :latest_submission, :boolean, default: false
  end
end
