class Admin::SubmissionNotificationJob < ApplicationJob
  def perform(submission)
    admin_ids.each do |admin_id|
      email_preference = EmailPreference.where(participant_id: admin_id).first
      Admin::SubmissionNotificationMailer.new.sendmail(admin_id, submission.id) if email_preference.email_frequency == :every
    end
  end
end
