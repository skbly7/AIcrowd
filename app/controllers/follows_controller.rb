class FollowsController < ApplicationController
  before_action :authenticate_participant!
  before_action :set_followable
  respond_to :js

  def create
    @follow             = @followable.follows.new
    @follow.participant = current_participant
    @follow.save

    respond_to do |format|
      format.js { render :refresh }
    end
  end

  def destroy
    Follow.destroy(params[:id])

    respond_to do |format|
      format.js { render :refresh }
    end
  end

  private

  def set_followable
    params.each do |key, val|
      if key =~ /(.+)_id$/
        @followable = Regexp.last_match(1).classify.constantize.find(val)
        break
      end
    end
  end
end
