# frozen_string_literal: true
class Team::BaseMailer < ApplicationMailer
  protected def format_options
    options = {
      participant_id:    @participant.id,
      subject:           "[AIcrowd] #{email_subject}",
      to:                @participant.email,
      template:          'AIcrowd General Template',
      global_merge_vars: [
        {
          name:    'NAME',
          content: @participant.name.to_s
        },
        {
          name:    'BODY',
          content: email_body_html
        },
        { name:    'EMAIL_PREFERENCES_LINK',
          content: email_prefs_html }
      ]
    }
  end

  protected def set_participant_from_invitee(invitee)
    case invitee
    when Participant
      @participant = invitee
    when EmailInvitation
      @participant = Participant.new(
        name:  invitee.email.sub(/@.*\z/, ''),
        email: invitee.email
      )
    else
      raise "Unexpected invitee type: #{@invitee.class}"
    end
  end

  protected def linked_team_html
    @linked_team_html ||= begin
      if @team.persisted?
        "Team #{link_to(@team.name, challenge_team_url(@team.challenge, @team))}"
      else
        "Team “#{@team.name}”"
      end
    end
  end

  protected def linked_challenge_html
    @linked_challenge_html ||= link_to(@team.challenge.challenge, challenge_url(@team.challenge))
  end

  protected def linked_invitee_html
    @linked_invitee_html ||= begin
      case @invitee
      when Participant
        "Participant #{link_to(@invitee.name, participant_url(@invitee))}"
      when EmailInvitation
        "Participant #{mail_to(@invitee.email, @invitee.email.sub(/@.+\z/, ''))}"
      else
        '&lt;?&gt;'
      end
    end
  end

  protected def linked_invitor_html
    @linked_invitor_html ||= link_to(@invitor.name, participant_url(@invitor))
  end

  protected def signoff_html
    @signoff_html ||= <<~HTML
      <br>
      <p>
        Best regards,
        <br>
        AIcrowd
      </p>
    HTML
  end

  private def email_prefs_html
    return '' unless @participant.persisted?

    preamble   = 'You are receiving this email for the following reason:'
    url        = EmailPreferencesTokenService.new(@participant).preferences_token_url
    prefs_link = %(<a href="#{url}">Email Preferences</a>)
    <<~HTML
      <div>
        <p><small>
          #{preamble} #{notification_reason} #{prefs_link}
        </small></p>
      </div>
    HTML
  end
end
