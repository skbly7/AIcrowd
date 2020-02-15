module TeamHelper
  def my_team_view_or_create_button(challenge)
    return nil unless challenge.teams_allowed

    button_opts = {}
    my_team     = current_participant&.teams&.for_challenge(challenge)&.first
    if my_team
      setup_opts_for_my_team_button(button_opts, my_team)
    else
      setup_opts_for_create_team_button(button_opts, challenge)
    end
    themed_button(button_opts)
  end

  def team_invitation_cancel_button(invitation)
    button_opts = {}
    setup_opts_for_invitation_cancel_button(button_opts, invitation)
    themed_button(button_opts)
  end

  def team_member_invite_button(team)
    button_opts = {}
    setup_opts_for_member_invite_button(button_opts, team)
    themed_button(button_opts)
  end

  private def setup_opts_for_create_team_button(opts, challenge)
    opts[:small] = true
    opts[:class] = 'pull-right mr-1'
    opts[:title] = t(:title, scope: %i[helpers teams create_button])
    issues       = {}
    if policy(challenge).create_team?(issues)
      tooltip_sym  = :allowed
      opts[:modal] = '#create-team-modal'
    else
      tooltip_sym     = issues[:sym]
      opts[:disabled] = true
    end
    opts[:tooltip] = t(
      tooltip_sym,
      scope:   %i[helpers teams create_button tooltip],
      default: :unspecified
    )
  end

  private def setup_opts_for_my_team_button(opts, team)
    opts[:small]   = true
    opts[:class]   = 'pull-right mr-1'
    i18n_params    = { scope: %i[helpers teams my_team_button] }
    opts[:title]   = t(:title, **i18n_params)
    opts[:tooltip] = t(:tooltip, team_name: team.name.to_s, **i18n_params)
    opts[:link]    = team_path(team)
  end

  private def setup_opts_for_member_invite_button(opts, team)
    opts[:title] = t(:title, scope: %i[helpers teams invite_member_button])
    issues       = {}
    if policy(team).create_invitations?(issues)
      tooltip_sym  = :allowed
      opts[:modal] = '#invite-team-member-modal'
    else
      tooltip_sym     = issues[:sym]
      opts[:disabled] = true
    end
    opts[:tooltip] = t(
      tooltip_sym,
      scope:   %i[helpers teams invite_member_button tooltip],
      default: :unspecified
    )
  end

  private def setup_opts_for_invitation_cancel_button(opts, inv)
    opts[:small] = true
    opts[:title] = t(:title, scope: %i[helpers teams cancel_invitation_button])
    if policy(inv.team).cancel_invitations?
      opts[:link] = {
        url:    team_invitation_cancellations_path(inv),
        method: :post
      }
      opts[:confirm] = t(:confirm, scope: %i[helpers teams cancel_invitation_button])
      tooltip_sym    = :allowed
    else
      opts[:disabled] = true
      tooltip_sym     = :participant_not_organizer
    end
    opts[:tooltip] = t(
      tooltip_sym,
      scope: %i[helpers teams cancel_invitation_button tooltip]
    )
  end
end
