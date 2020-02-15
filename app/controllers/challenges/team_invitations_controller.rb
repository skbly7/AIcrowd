class Challenges::TeamInvitationsController < ApplicationController
  before_action :authenticate_participant!
  before_action :set_challenge
  before_action :set_team
  before_action :set_invitation, only: [:show, :edit, :update, :destroy]
  before_action :set_invitee, only: :create
  before_action :redirect_on_create_disallowed, only: :create

  def create
    @invitation = @team.team_invitations.new(
      invitor: current_participant,
      invitee: @invitee
    )

    if @invitation.save
      Team::InvitationPendingNotifierJob.perform_later(@invitation.id)
      flash[:success] = I18n.t(:success, scope: %i[helpers teams create_invitation_flash])
    else
      flash[:error] = error_msg(:unspecified)
    end
    redirect_to challenge_team_path(@team.challenge, @team)
  end

  private

  def set_challenge
    @challenge = Challenge.friendly.find(params[:challenge_id])
  end

  def set_team
    @team = @challenge.teams.find_by!(name: params[:team_name])
  end

  def set_invitee
    name_or_email = params[:invitee] || ''
    @search_field = name_or_email&.match?(Devise.email_regexp) ? :email : :name

    case @search_field
    when :email
      @invitee = Participant.where('LOWER(email) = LOWER(?)', name_or_email).first ||
        EmailInvitation.new(
          invitor_id: current_participant.id,
          email:      name_or_email
        )
    when :name
      @invitee = Participant.where('LOWER(name) = LOWER(?)', name_or_email).first
    end
  end

  def set_invitation
    @invitation = @team.team_invitations.find(params[:id])
  end

  def redirect_on_create_disallowed
    issues = {}
    if !policy(@team).create_invitations?(issues)
      err = issues[:sym]
    elsif @invitee.nil?
      err = :invitee_nil
    elsif @invitee.is_a?(Participant)
      if @team.team_participants.exists?(participant_id: @invitee.id)
        err = :invitee_on_this_team_confirmed
      elsif @team.team_invitations_pending.exists?(invitee: @invitee)
        err = :invitee_on_this_team_pending
      elsif @invitee.concrete_teams.exists?(challenge_id: @team.challenge_id)
        err = :invitee_on_other_team
      end
    elsif @invitee.is_a?(EmailInvitation)
      if @team.team_invitations_pending
          .joins(:invitee_email_invitation)
          .exists?(email_invitations: { email: @invitee.email })
        err = :invitee_on_this_team_pending
      end
    end
    if err
      flash[:error] = error_msg(err)
      redirect_to challenge_team_path(@team.challenge, @team)
    end
  end

  def error_msg(key)
    i18n_scope = %i[helpers teams create_invitation_flash]
    msg        = ''
    msg << I18n.t(:error_preamble, scope: i18n_scope)
    msg << ' '
    msg << I18n.t(key, scope: i18n_scope, default: :unspecified)
    msg.freeze
  end
end
