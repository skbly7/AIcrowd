class Team::InvitationCanceledNotifierJob < ApplicationJob
  queue_as :default

  def perform(invitation_id)
    inv = TeamInvitation.find(invitation_id)
    Team::Invitee::InvitationCanceledNotificationMailer.new.sendmail(inv)
  end
end
