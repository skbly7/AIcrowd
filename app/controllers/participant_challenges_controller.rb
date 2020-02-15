class ParticipantChallengesController < ApplicationController
  before_action :authenticate_participant!
  before_action :set_challenge, only: [:index, :approve, :deny]
  before_action :set_vote, only: :index
  before_action :set_follow, only: :index
  respond_to :html, :js

  def index
    @challenge_rounds       = @challenge.challenge_rounds.where("start_dttm < ?", Time.current)
    @count_of_unknown       = @challenge.challenge_participants.where(participant_id: nil).count
    @participant_challenges = @challenge
                                  .challenge_participants
                                  .where.not(participant_id: nil)
                                  .order('updated_at asc')
                                  .page(params[:page])
                                  .per(10)
    authorize @participant_challenges
  end

  private

  def set_challenge
    @challenge = Challenge.find(params[:challenge_id])
  end

  def set_vote
    @vote = @challenge.votes.where(participant_id: current_participant.id).first if current_participant.present?
  end

  def set_follow
    @follow = @challenge.follows.where(participant_id: current_participant.id).first if current_participant.present?
  end
end
