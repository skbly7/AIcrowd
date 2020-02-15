# frozen_string_literal: true
class Team::Organizer::InvitationDeclinedNotificationMailer < Team::BaseMailer
  def sendmail(participant, invitation)
    @participant = participant
    @team        = invitation.team
    @invitee     = invitation.invitee
    mandrill_send(format_options)
  end

  def email_subject
    'Team Invitation Declined'
  end

  def email_body_html
    <<~HTML
      <div>
        <p>#{linked_invitee_html} just declined an invitation to join #{linked_team_html}.</p>
        #{signoff_html}
      </div>
    HTML
  end

  def notification_reason
    'Someone declined an invitation to a team you organize.'
  end
end
