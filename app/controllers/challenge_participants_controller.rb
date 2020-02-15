class ChallengeParticipantsController < ApplicationController
  before_action :authenticate_participant!

  def create
    @challenge                            = Challenge.friendly.find(params[:challenge_id])
    @challenge_participant                = @challenge.challenge_participants.new(challenge_participant_params)
    @challenge_participant.participant_id = current_participant.id

    authorize @challenge_participant

    if @challenge_participant.save
      redirect_to(session[:forwarding_url] || @challenge)
      session.delete(:forwarding_url)
    else
      render :new
    end
  end

  def update
    @challenge_participant = ChallengeParticipant.find(params[:id])
    authorize @challenge_participant
    @challenge_participant.challenge_rules_accepted_date    = Time.now
    @challenge_participant.challenge_rules_accepted_version = @challenge_participant.challenge.current_challenge_rules_version
    if @challenge_participant.update(challenge_participant_params)
      redirect_to(session[:forwarding_url] || @challenge_participant.challenge)
      session.delete(:forwarding_url)
    else
      render :edit
    end
  end

  private

  def challenge_participant_params
    params
      .require(:challenge_participant)
      .permit(
        :challenge_rules_additional_checkbox,
        :challenge_rules_accepted_version
      )
  end
end
