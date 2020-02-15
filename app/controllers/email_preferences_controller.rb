class EmailPreferencesController < ApplicationController
  before_action :set_participant
  before_action :email_preferences_token_or_authenticate

  def edit; end

  def update
    if @participant.update(participant_params)
      flash[:notice] = 'Your email preferences were successfully updated.'
      redirect_to(session['participant_return_to']) && return if session['participant_return_to']
      if @token
        redirect_to participant_notifications_path(@participant, preferences_token: @token)
      else
        redirect_to participant_notifications_path(@participant)
      end
    else
      render :edit
    end
  end

  private

  def set_participant
    @participant = Participant.friendly.find(params[:participant_id])
  end

  def participant_params
    params.require(:participant).permit(:agreed_to_marketing)
  end

  def email_preferences_token_or_authenticate
    token = params[:preferences_token]
    Rails.logger.info("[EmailPreferencesController#email_preferences_token_or_authenticate] token: #{token}")
    if token.present?
      status = EmailPreferencesTokenService.new(@participant).validate_token(token)
      case status
      when 'invalid_participant'
        flash[:error] = 'The email preferences link is not valid for the currently logged in participant.'
        redirect_to '/'
      when 'valid_token'
        sign_in(:participant, @participant)
        @email_preference = current_participant.email_preferences.first
      when 'token_expired'
        flash[:error] = 'The email preferences link has expired.'
        redirect_to new_participant_session_path
      when 'invalid_token'
        flash[:error] = 'The email preferences link is invalid.'
        redirect_to new_participant_session_path
      end
    else
      authenticate_participant!
    end
  end
end
