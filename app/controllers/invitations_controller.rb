class InvitationsController < ApplicationController
  before_action :set_challenge

  def import
    InvitationImporter.new(file: params[:file], challenge_id: @challenge.id).call
    redirect_to edit_challenge_path(@challenge)
  end

  private

  def set_challenge
    @challenge = Challenge.friendly.find(params[:challenge_id])
  end
end
