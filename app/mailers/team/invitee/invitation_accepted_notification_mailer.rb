# frozen_string_literal: true
class Team::Invitee::InvitationAcceptedNotificationMailer < Team::BaseMailer
  def sendmail(invitation)
    set_participant_from_invitee(invitation.invitee)
    @team = invitation.team
    mandrill_send(format_options)
  end

  def email_subject
    "Welcome to Team #{@team.name}"
  end

  def email_body_html
    other_team_member_count = @team.team_participants.count - 1
    n_other_people          = "#{other_team_member_count} other #{other_team_member_count == 1 ? 'person' : 'people'}"
    <<~HTML
      <div>
        <p>You’ve just joined #{linked_team_html}!</p>
        <p>
          You will now be collaborating with #{n_other_people} on #{linked_challenge_html}.
          A submission by any one of you will count the same for all of you on the
          leaderboard. Good luck on the challenge!
        </p>
        #{signoff_html}
      </div>
    HTML
  end

  def notification_reason
    'You joined a team.'
  end
end
