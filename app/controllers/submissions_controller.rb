class SubmissionsController < ApplicationController
  before_action :authenticate_participant!, except: [:index, :show]
  before_action :set_submission, only: [:show, :edit, :update]
  before_action :set_challenge
  before_action :set_challenge_rounds, only: [:index, :new, :show]
  before_action :set_vote, only: [:index, :new, :show]
  before_action :set_follow, only: [:index, :new, :show]
  before_action :check_participation_terms, except: [:show, :index]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]
  before_action :set_submissions_remaining, except: [:show, :index]
  before_action :set_current_round, only: :index

  layout :set_layout
  respond_to :html, :js

  def index
    @current_round_id = @current_round&.id

    if params[:baselines] == 'true'
      @search = policy_scope(Submission)
                    .where(
                      challenge_round_id: @current_round_id,
                      challenge_id:       @challenge.id,
                      baseline:           true)
                    .where.not(participant_id: nil)
                    .search(search_params)
      @baselines = true
    else
      @baselines      = false
      @my_submissions = true if params[:my_submissions] == 'true' && current_participant
      if @my_submissions
        @search = policy_scope(Submission)
                      .where(
                        challenge_round_id: @current_round_id,
                        challenge_id:       @challenge.id,
                        participant_id:     current_participant.id)
                      .search(search_params)
        @submissions_remaining = SubmissionsRemainingQuery.new(
          challenge:      @challenge,
          participant_id: current_participant.id).call
      else
        @search = policy_scope(Submission)
                      .where(
                        challenge_round_id: @current_round_id,
                        challenge_id:       @challenge.id)
                      .search(search_params)
      end
    end
    @search.sorts = 'created_at desc' if @search.sorts.empty?
    @submissions  = @search.result.includes(:participant).page(params[:page]).per(10)
  end

  def filter
    Rails.logger.debug('PARAMS Q')
    Rails.logger.debug(params[:q])
    @search      = policy_scope(Submission).ransack(params[:q])
    @submissions = @search.result
                       .where(challenge_id: @challenge.id)
                       .page(1).per(10)
    render @submissions
  end

  def show
    @presenter = SubmissionDetailPresenter.new(
      submission:   @submission,
      challenge:    @challenge,
      view_context: view_context
    )
    render :show
  end

  def new
    @clef_primary_run_disabled          = clef_primary_run_disabled?
    @submissions_remaining, @reset_dttm = SubmissionsRemainingQuery.new(
      challenge:      @challenge,
      participant_id: current_participant.id
    ).call
    @submission = @challenge.submissions.new
    @submission.submission_files.build
    authorize @submission
  end

  def create
    @submission = @challenge.submissions.new(
      submission_params
          .merge(
            participant_id:    current_participant.id,
            online_submission: true))
    authorize @submission
    if @submission.save
      SubmissionGraderJob.perform_later(@submission.id)
      redirect_to challenge_submissions_path(@challenge),
                  notice: 'Submission accepted.'
    else
      @errors = @submission.errors
      render :new
    end
  end

  def edit
    authorize @submission
  end

  def update
    authorize @submission
    if @submission.update(submission_params)
      redirect_to @challenge,
                  notice: 'Submission updated.'
    else
      render :edit
    end
  end

  def destroy
    submission = Submission.find(params[:id])
    submission.destroy
    redirect_to challenge_leaderboards_path(@challenge),
                notice: 'Submission was successfully destroyed.'
  end

  private

  def set_submission
    @submission = Submission.find(params[:id])
    authorize @submission
  end

  def set_challenge
    @challenge = Challenge.friendly.find(params[:challenge_id])
  end

  def set_challenge_rounds
    @challenge_rounds = @challenge.challenge_rounds.where("start_dttm < ?", Time.current)
  end

  def set_vote
    @vote = @challenge.votes.where(participant_id: current_participant.id).first if current_participant.present?
  end

  def set_follow
    @follow = @challenge.follows.where(participant_id: current_participant.id).first if current_participant.present?
  end

  def set_current_round
    @current_round = if params[:challenge_round_id].present?
                       ChallengeRound.find(params[:challenge_round_id].to_i)
                     else
                       @challenge.challenge_rounds.where(active: true).first
                     end
  end

  def check_participation_terms
    unless policy(@challenge).has_accepted_participation_terms?
      redirect_to [@challenge, ParticipationTerms.current_terms]
      return
    end

    unless policy(@challenge).has_accepted_challenge_rules?
      redirect_to [@challenge, @challenge.current_challenge_rules]
      return
    end
  end

  def grader_logs
    if @challenge.grader_logs
      s3_key       = "grader_logs/#{@challenge.slug}/grader_logs_submission_#{@submission.id}.txt"
      s3           = S3Service.new(s3_key)
      @grader_logs = s3.filestream
    end
    return @grader_logs
  end

  def submission_params
    params
        .require(:submission)
        .permit(
          :challenge_id,
          :participant_id,
          :description_markdown,
          :score,
          :score_secondary,
          :grading_status,
          :grading_message,
          :api,
          :grading_status_cd,
          :media_content_type,
          :media_thumbnail,
          :media_large,
          :docker_configuration_id,
          :clef_method_description,
          :clef_retrieval_type,
          :clef_run_type,
          :clef_primary_run,
          :clef_other_info,
          :clef_additional,
          :online_submission,
          :baseline,
          :baseline_comment,
          submission_files_attributes: [
            :id,
            :seq,
            :submission_file_s3_key,
            :_delete
          ])
  end

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET
                          .presigned_post(
                            key:                   "submission_files/challenge_#{@challenge.id}/#{SecureRandom.uuid}_${filename}",
                            success_action_status: '201',
                            acl:                   'private')
  end

  def set_submissions_remaining
    @submissions_remaining = @challenge.submissions_remaining(current_participant.id)
  end

  def notify_admins
    Admin::SubmissionNotificationJob.perform_later(@submission)
  end

  def clef_primary_run_disabled?
    return true unless @challenge.organizer.clef?

    sql = %[
        SELECT 'X'
        FROM submissions s
        WHERE s.challenge_id = #{@challenge.id}
        AND s.participant_id = #{current_participant.id}
        AND ((s.clef_primary_run IS TRUE
              AND s.grading_status_cd = 'graded')
              OR s.grading_status_cd IN ('ready', 'submitted', 'initiated'))
      ]
    res = ActiveRecord::Base.connection.select_values(sql)
    res.any?
  end

  def set_layout
    return 'application'
  end
end
