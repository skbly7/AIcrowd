# frozen_string_literal: true
class Team::Organizer::InvitationAcceptedNotificationMailer < Team::BaseMailer
  def sendmail(participant, invitation)
    @participant = participant
    @team        = invitation.team
    @invitee     = invitation.invitee
    mandrill_send(format_options)
  end

  def email_subject
    'Team Invitation Accepted'
  end

  def email_body_html
    <<~HTML
      <div>
        <p>#{linked_team_html} has a new team member!</p>
        <p>#{linked_invitee_html} just accepted the invitation and is the newest member of the team.</p>
        #{signoff_html}
      </div>
    HTML
  end

  def notification_reason
    'Someone accepted an invitation to a team you organize.'
  end
end
