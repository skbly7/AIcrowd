# frozen_string_literal: true
class TeamInvitations::ClaimEmailsController < ApplicationController
  before_action :authenticate_participant!
  before_action :set_invitations, only: :create
  before_action :redirect_from_create_on_disallowed, only: :create

  def index; end

  def create
    ActiveRecord::Base.transaction do
      @claimed_email_invitation.update!(
        claimant_id: current_participant.id,
        claimed_at:  Time.zone.now
      )
      @invitations_to_transform.update_all(
        invitee_type: 'Participant',
        invitee_id:   current_participant.id
      )
    end
    flash[:success] = "You successfully claimed email #{@claimed_email_invitation.email}."
    redirect_to participant_path(current_participant, anchor: 'tab-teams')
  end

  private

  def set_invitations
    @email_claim_params = params.require(:email_claim).permit(
      :email_token,
      :email_confirmation
    )
    email_token               = Base31.normalize_s(@email_claim_params.fetch(:email_token, ''))
    email_confirmation        = @email_claim_params.fetch(:email_confirmation, '').strip
    @claimed_email_invitation = TeamInvitation.all
      .includes(:invitee_email_invitation)
      .where(email_invitations: {
               token: email_token,
               email: email_confirmation
             })
      .first
      &.invitee_email_invitation
    @invitations_to_transform = TeamInvitation.all
      .joins(:invitee_email_invitation)
      .where(email_invitations: {
               email: email_confirmation
             })
  end

  def redirect_from_create_on_disallowed
    if @claimed_email_invitation.nil?
      flash[:error] = 'Invalid claim'
      redirect_to claim_emails_path(@email_claim_params)
    end
  end
end
