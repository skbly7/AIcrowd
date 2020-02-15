class TeamPolicy < ApplicationPolicy
  alias_method :team, :record

  def show?
    true
  end

  # a participant can only create invitations if all the following conditions are true:
  #   - logged in
  #   - organizer of this team
  #   - team is not full
  #   - challenge has not frozen teams
  def create_invitations?(out_issues_hash = nil)
    cached_with_issues(:create_invitations?, out_issues_hash) do
      {
        participant_not_logged_in:
                                   participant.nil?,
        participant_not_organizer:
                                   !team.team_participants_organizer.exists?(participant_id: participant&.id),
        team_full:
                                   team.full?,
        challenge_teams_frozen:
                                   team.challenge.teams_frozen?
      }
    end
  end

  # only the team organizer can cancel invitations to new members
  def cancel_invitations?
    team.team_participants_organizer.exists?(participant_id: participant&.id)
  end

  # only team members can see who else is invited
  def show_invitations?
    team.team_participants.exists?(participant_id: participant&.id)
  end
end
