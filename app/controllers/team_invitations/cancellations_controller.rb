# frozen_string_literal: true
class TeamInvitations::CancellationsController < ApplicationController
  before_action :authenticate_participant!
  before_action :set_invitation
  before_action :set_team
  before_action :redirect_on_disallowed

  def create
    @invitation.update!(status: :canceled)
    Team::InvitationCanceledNotifierJob.perform_later(@invitation.id)
    flash[:success] = t('.success_flash', invitee: @invitation.invitee_name_or_email, team: @team.name)
    redirect_to challenge_team_path(@team.challenge, @team)
  end

  private

  def set_invitation
    @invitation = TeamInvitation.find_by!(uuid: params[:team_invitation_uuid])
  end

  def set_team
    @team = @invitation.team
  end

  def redirect_on_disallowed
    unless @team.team_participants_organizer.exists?(participant_id: current_participant.id)
      flash[:error] = 'Only an organizer of the team may cancel an invitation'
      redirect_to challenge_team_path(@team.challenge, @team)
    end
  end
end
