class Challenges::TeamsController < ApplicationController
  before_action :authenticate_participant!, except: [:show]
  before_action :set_challenge
  before_action :set_team, only: [:show]

  def create
    authorize @challenge, :create_team?
    @team = @challenge.teams.new(create_team_attributes)
    @team.team_participants.build(participant_id: current_participant.id, role: :organizer)

    if @team.save
      BaseLeaderboard.morph_submitter!(
        from:         current_participant,
        to:           @team,
        challenge_id: @challenge.id
      )
      flash[:success] = 'Team created successfully'
      redirect_to challenge_team_path(@team.challenge, @team)
    else
      flash[:error] = @team.errors.full_messages.to_sentence
      redirect_to @challenge
    end
  end

  def show
    @pending_invitations = @team.team_invitations
      .status_pendings
      .includes(:invitee)
  end

  private

  def set_challenge
    @challenge = Challenge.friendly.find(params[:challenge_id])
  end

  def set_team
    @team = @challenge.teams.find_by!(name: params[:name])
    authorize @team
  end

  def create_team_attributes
    params
      .fetch(:team, {})
      .permit(:name)
  end
end
