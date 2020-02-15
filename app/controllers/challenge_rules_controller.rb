class ChallengeRulesController < ApplicationController
  before_action :authenticate_participant!
  before_action :set_challenge_rules

  def show; end

  private

  def set_challenge_rules
    @challenge_rules       = params[:id] && ChallengeRules.find(params[:id])
    @challenge             = @challenge_rules.challenge
    @challenge_participant =
      ChallengeParticipant
        .where(challenge_id: @challenge.id, participant_id: current_participant.id)
        .first_or_create
    @challenge_participant.challenge_rules_accepted_version = @challenge_rules.version
  end
end
