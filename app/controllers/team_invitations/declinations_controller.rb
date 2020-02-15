# frozen_string_literal: true
class TeamInvitations::DeclinationsController < ApplicationController
  before_action :set_invitation
  before_action :set_team
  before_action :set_invitee
  before_action :authenticate_participant!, unless: -> { @invitee.is_a?(EmailInvitation) }
  before_action :redirect_on_disallowed

  def index
    @challenge = @team.challenge
  end

  def create
    @invitation.update!(status: :declined)
    Team::InvitationDeclinedNotifierJob.perform_later(@invitation.id)
    flash[:success] = 'You successfully declined the invitation'
    redirect_to @team.challenge
  end

  private

  def set_invitation
    @invitation = TeamInvitation.find_by!(uuid: params[:team_invitation_uuid])
  end

  def set_team
    @team = @invitation.team
  end

  def set_invitee
    @invitee = @invitation.invitee
  end

  def redirect_on_disallowed
    if @invitee.is_a?(EmailInvitation) && !@invitee.token_eq?(params[:email_token])
      flash[:error] = 'Please use the link you were sent by email and try again'
      redirect_to root_path
    elsif @invitee.is_a?(Participant) && @invitee != current_participant
      flash[:error] = 'You may not decline an invitation on someone else’s behalf'
      redirect_to root_path
    elsif current_participant && @team.team_participants.exists?(participant_id: current_participant.id)
      flash[:error] = 'You are already a member of this team'
      redirect_to challenge_team_path(@team.challenge, @team)
    elsif @invitation.status != :pending
      flash[:error] = 'This invitation is no longer valid'
      redirect_to challenge_team_path(@team.challenge, @team)
    elsif @team.challenge.teams_frozen?
      flash[:error] = 'The challenge has team-freeze in effect'
      redirect_to @team.challenge
    elsif current_participant.concrete_teams.where.not(id: @team.id).exists?(challenge_id: @team.challenge_id)
      flash[:error] = 'You are already a member of a different team for this challenge'
      redirect_to @team.challenge
    end
  end
end
