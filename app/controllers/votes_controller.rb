class VotesController < ApplicationController
  before_action :authenticate_participant!
  before_action :set_votable
  respond_to :js

  def create
    @vote             = @votable.votes.new
    @vote.participant = current_participant
    authorize @vote
    @vote.save
    @votable.update(vote_count: @votable.votes.count)
    Rails.logger.debug("updated: #{@votable.id}")

    respond_to do |format|
      format.js { render :refresh }
    end
  end

  def destroy # unvote
    Vote.destroy(params[:id])

    @vote = @votable.votes.where(participant_id: current_participant.id).first if current_participant.present?
    @votable.update(vote_count: @votable.votes.count)

    Rails.logger.debug "rendering destroy #{@votable}"

    respond_to do |format|
      format.js { render :refresh }
    end
  end

  private

  def set_votable
    params.each do |key, val|
      if key =~ /(.+)_id$/
        @votable = Regexp.last_match(1).classify.constantize.find(val)
        break
      end
    end
  end
end
