class Team::InvitationPendingNotifierJob < ApplicationJob
  queue_as :default

  def perform(invitation_id)
    inv = TeamInvitation.find(invitation_id)
    Team::Invitee::InvitationPendingNotificationMailer.new.sendmail(inv)
  end
end
