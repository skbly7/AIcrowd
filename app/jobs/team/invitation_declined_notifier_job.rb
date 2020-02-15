class Team::InvitationDeclinedNotifierJob < ApplicationJob
  queue_as :default

  def perform(invitation_id)
    inv = TeamInvitation.find(invitation_id)
    inv.team.team_participants_organizer.each do |tp|
      Team::Organizer::InvitationDeclinedNotificationMailer.new.sendmail(tp.participant, inv)
    end
  end
end
