# This is a legacy controller.
# A team without a specified challenge might have name aliasing issues
# so we redirect to the correct page
class TeamsController < ApplicationController
  before_action :set_team

  def show
    redirect_to challenge_team_path(@team.challenge, @team), status: 301
  end

  private

  def set_team
    @team = Team.order(:id).find_by!(name: params[:name])
    authorize @team
  end
end
