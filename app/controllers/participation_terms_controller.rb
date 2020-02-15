class ParticipationTermsController < ApplicationController
  before_action :authenticate_participant!
  before_action :set_participation_terms

  def show
    @challenge = Challenge.friendly.find(params[:challenge_id])
  end

  private

  def set_participation_terms
    @participation_terms = ParticipationTerms.current_terms
  end
end
