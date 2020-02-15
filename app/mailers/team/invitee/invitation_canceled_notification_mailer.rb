# frozen_string_literal: true
class Team::Invitee::InvitationCanceledNotificationMailer < Team::BaseMailer
  def sendmail(invitation)
    set_participant_from_invitee(invitation.invitee)
    @team = invitation.team
    mandrill_send(format_options)
  end

  def email_subject
    'Your Invitation Was Canceled'
  end

  def email_body_html
    <<~HTML
      <div>
        <p>Previously, you had been invited to join #{linked_team_html}. Unfortunately, your invitation has been canceled at this time.</p>
        #{signoff_html}
      </div>
    HTML
  end

  def notification_reason
    'Someone canceled your invitation to a team.'
  end
end
