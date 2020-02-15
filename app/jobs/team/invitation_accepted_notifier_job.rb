class Team::InvitationAcceptedNotifierJob < ApplicationJob
  queue_as :default

  def perform(invitee_id, mails)
    TeamInvitation\
      .where(id: mails[:accepted_invitations])
      .includes(team: { team_participants_organizer: :participant })
      .each do |inv|
        inv.team.team_participants_organizer.each do |tp|
          Team::Organizer::InvitationAcceptedNotificationMailer.new.sendmail(tp.participant, inv)
        end
        Team::Invitee::InvitationAcceptedNotificationMailer.new.sendmail(inv)
      end

    TeamInvitation\
      .where(id: mails[:declined_invitations])
      .includes(team: { team_participants_organizer: :participant })
      .each do |inv|
        inv.team.team_participants_organizer.each do |tp|
          Team::Organizer::InvitationDeclinedNotificationMailer.new.sendmail(tp.participant, inv)
        end
      end

    canceled = Hash[mails[:canceled_invitations].map { |x| [x[:invitation][:invitee_id], x] }]
    Participant.where(id: canceled.keys).each do |participant|
      # replace id with instance to avoid re-loading it in the mailer
      data = canceled[participant.id].deep_merge({ invitation: { invitee_id: nil, invitee: participant } })
      # mock instances because the invitation and team no longer exist
      inv      = TeamInvitation.new(data[:invitation])
      inv.team = Team.new(data[:team])
      Team::Invitee::InvitationCanceledNotificationMailer.new.sendmail(inv)
    end
  end
end
