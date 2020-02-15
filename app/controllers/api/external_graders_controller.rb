class Api::ExternalGradersController < Api::BaseController
  before_action :auth_by_api_key, only: [:show, :update]
  before_action :auth_by_api_key_and_client_id, only: [:create]

  def show # GET
    Rails.logger.info "[api] Api::ExternalGradersController#get"
    Rails.logger.info "[api] params: #{params}"
    participant = Participant.where(api_key: params[:id]).first
    if participant.present?
      message        = "Developer API key is valid"
      participant_id = participant.id
      status         = :ok
    else
      message        = "No participant could be found for this API key"
      participant_id = nil
      status         = :not_found
    end
    Rails.logger.info "API: #{message}"
    render json: { message: message, participant_id: participant_id }, status: status
  end

  def create # POST
    Rails.logger.info "[api] Api::ExternalGradersController#create"
    Rails.logger.info "[api] params: #{params}"
    message               = nil
    status                = nil
    submission_id         = nil
    submissions_remaining = nil
    reset_dttm            = nil
    begin
      participant = Participant.where(api_key: params[:api_key]).first
      raise DeveloperAPIKeyInvalid if participant.nil?
      raise ParticipantDidNotAcceptParticipationTerms unless participant.has_accepted_participation_terms?

      challenge = Challenge.where(challenge_client_name: params[:challenge_client_name]).first
      raise ChallengeClientNameInvalid if challenge.nil?
      raise ParticipantDidNotAcceptChallengeRules unless challenge.has_accepted_challenge_rules?(participant)

      challenge_round_id = get_challenge_round_id(challenge: challenge, params: params)

      raise ChallengeRoundNotOpen unless challenge_round_open?(challenge)
      raise ParticipantNotQualified unless participant_qualified?(challenge, participant)
      raise ParallelSubmissionLimitExceeded unless parallel_submissions_allowed?(challenge, participant)

      challenge_participant = challenge
        .challenge_participants
        .find_by(participant_id: participant.id)

      raise TermsNotAcceptedByParticipant if challenge_participant.blank?

      submissions_remaining, reset_dttm = challenge.submissions_remaining(participant.id)
      raise NoSubmissionSlotsRemaining, reset_dttm if submissions_remaining < 1

      params[:meta] = clean_meta(params[:meta]) if params[:meta].present?
      submission    = Submission
        .create!(
          participant_id:       participant.id,
          challenge_id:         challenge.id,
          challenge_round_id:   challenge_round_id,
          description_markdown: params[:description_markdown],
          post_challenge:       post_challenge(challenge, params),
          meta:                 params[:meta])
      if media_fields_present?
        submission.update(
          media_large:        params[:media_large],
          media_thumbnail:    params[:media_thumbnail],
          media_content_type: params[:media_content_type])
      end

      # Post challenge submissions
      # messy hack - to be refactored
      if submission.post_challenge.present?
        if submission.challenge.post_challenge_submissions.blank?
          submission.update(
            grading_status_cd: 'failed',
            grading_message:   'Submission made after end of round.')
        else
          submission.submission_grades.create!(grading_params)
        end
      else
        submission.submission_grades.create!(grading_params)
      end

      submission_id = submission.id
      notify_admins(submission)

      submissions_remaining, reset_dttm = challenge.submissions_remaining(participant.id)
      message                           = "Participant #{participant.name} scored"
      status                            = :accepted
    rescue StandardError => e
      status  = :bad_request
      message = e
    ensure
      Rails.logger.info "API: #{message}"
      render json: { message:               message,
                     submission_id:         submission_id,
                     submissions_remaining: submissions_remaining,
                     reset_dttm:            reset_dttm }, status: status
    end
  end

  def update # PATCH
    Rails.logger.info "[api] Api::ExternalGradersController#update"
    Rails.logger.info "[api] params: #{params}"
    message               = nil
    status                = nil
    submission_id         = params[:id]
    submissions_remaining = nil
    reset_date            = nil
    begin
      submission = Submission.find(submission_id)
      raise SubmissionIdInvalid if submission.blank?

      post_challenge                    = submission.post_challenge # preserve post_challenge status
      challenge                         = submission.challenge
      submissions_remaining, reset_date = challenge.submissions_remaining(submission.participant_id)
      if media_fields_present?
        submission.update(
          media_large:        params[:media_large],
          media_thumbnail:    params[:media_thumbnail],
          media_content_type: params[:media_content_type])
        unless params[:media_content_type] == 'video/youtube' || Rails.env.test?
          S3Service.new(params[:media_large]).make_public_read
          S3Service.new(params[:media_thumbnail]).make_public_read
        end
      end

      # Handle `meta` param
      if params[:meta].present?
        # Standardise params[:meta] to a Hash, irrespective of the
        # version of the API
        params[:meta] = clean_meta(params[:meta])

        if submission.meta.nil?
          meta = params[:meta]
        else
          if params[:meta_overwrite].present? && params[:meta_overwrite]
            # When the provided parameters have a `meta_overwrite=True`
            # parrameter, then a merge between the provided meta param
            # and the submission meta param will *NOT* happen. In this
            # case, the provided meta_param will overwrite the submission's
            # meta param.
            meta = params[:meta]
          else
            # Standardise submission.meta to a Hash, irrespective of the
            # version of the API
            submission_meta = clean_meta(submission.meta)
            meta            = submission_meta.reverse_merge!(params[:meta])
          end
        end
        submission.update({ meta: meta })
      end

      submission.submission_grades.create!(grading_params) if params[:grading_status].present?
      submission.description_markdown = params[:description_markdown] if params[:description_markdown].present?

      submission.post_challenge = post_challenge
      submission.save
      message = "Submission #{submission.id} updated"
      status  = :accepted
    rescue StandardError => e
      status  = :bad_request
      message = e
    ensure
      Rails.logger.info "API: #{message}"
      render json:   {
        message:               message,
        submission_id:         submission_id,
        submissions_remaining: submissions_remaining,
        reset_date:            reset_date
      },
             status: status
    end
  end

  def submission_info
    submission = Submission.find(params[:id])
    raise SubmissionIdInvalid if submission.blank?

    message = 'Submission details found.'
    body    = submission.to_json
    status  = :ok
  rescue StandardError => e
    status  = :bad_request
    body    = nil
    message = e
  ensure
    Rails.logger.info message
    render json: { message: message,
                   body:    body }, status: status
  end

  def presign
    participant = Participant.where(api_key: params[:id]).first
    if participant.present?
      s3_key         = "submissions/#{SecureRandom.uuid}"
      signer         = Aws::S3::Presigner.new
      presigned_url  = signer.presigned_url(:put_object, bucket: ENV['AWS_S3_SHARED_BUCKET'], key: s3_key)
      message        = "Presigned url generated"
      participant_id = participant.id
      status         = :ok
    else
      message        = "No participant could be found for this API key"
      participant_id = nil
      presigned_url  = nil
      status         = :not_found
    end
    render json: { message: message, participant_id: participant_id, s3_key: s3_key, presigned_url: presigned_url }, status: status
  end

  def post_challenge(challenge, params)
    return true if params[:post_challenge] == "true"
    return false if params[:post_challenge] == "false"
    if DateTime.now > challenge.end_dttm
      return true
    else
      return false
    end
  end

  class DeveloperAPIKeyInvalid < StandardError
    def initialize(msg = "The API key did not match any participant record.")
      super
    end
  end

  class ChallengeClientNameInvalid < StandardError
    def initialize(msg = "The Challenge Client Name string did not match any challenge.")
      super
    end
  end

  class GradingStatusInvalid < StandardError
    def initialize(msg = "Grading status must be one of (graded|failed|initiated)")
      super
    end
  end

  class GradingMessageMissing < StandardError
    def initialize(msg = "Grading message must be provided if grading = failed")
      super
    end
  end

  class SubmissionIdInvalid < StandardError
    def initialize(msg = "Submission ID is invalid.")
      super
    end
  end

  class NoSubmissionSlotsRemaining < StandardError
    def initialize(reset_time = nil)
      @reset_time = reset_time
      super(message)
    end

    def message
      if @reset_time
        "The participant has no submission slots remaining for today. Please wait until #{@reset_time} to make your next submission."
      else
        "The participant has no submission slots remaining for today."
      end
    end
  end

  class MediaFieldsIncomplete < StandardError
    def initialize(msg = 'Either all or none of media_large, media_thumbnail and media_content_type must be provided.')
      super
    end
  end

  class ChallengeRoundNotOpen < StandardError
    def initialize(msg = 'The challenge is not open for submissions at this time. Please check the challenge page at www.aicrowd.com')
      super
    end
  end

  class InvalidChallengeRoundID < StandardError
    def initialize(msg = 'This challenge_round_id does not exist')
      super
    end
  end

  class ParticipantNotQualified < StandardError
    def initialize(msg = 'You have not qualified for this round. Please review the challenge rules at www.aicrowd.com')
      super
    end
  end

  class ParallelSubmissionLimitExceeded < StandardError
    def initialize(msg = 'You have exceeded the allowed number of parallel submissions. Please wait until your other submission(s) are graded.')
      super
    end
  end

  class ParticipantDidNotAcceptParticipationTerms < StandardError
    def initialize(msg = 'You have not accepted the current AIcrowd Participation Terms. Please go to the challenge page on www.aicrowd.com and click on the "participate" button.')
      super
    end
  end

  class ParticipantDidNotAcceptChallengeRules < StandardError
    def initialize(msg = 'You have not accepted the current Challenge Rules. Please go to the challenge page on www.aicrowd.com and click on the "participate" button.')
      super
    end
  end

  class TermsNotAcceptedByParticipant < StandardError
    def initialize(msg = 'Invalid Submission. Have you registered for this challenge and agreed to the participation terms?')
      super
    end
  end

  private

  def clean_meta(params_meta)
    # Backward Compatibility
    # Across differrent versions of this API we have been passing
    # `meta` as a string, serialized JSON, and a hash.
    # This function consistently returns a Hash by parsing the
    # meta field depending of if its a string, serrialized json or a hash.
    #
    if params_meta.respond_to?(:keys)
      return params_meta
    else
      begin
        # Try to parse it as a JSON
        return JSON.parse(params_meta)
      rescue Exception => e
        # If its a string which is not a valid JSON
        # Then this is from the corrupted data
        # because of this bug :
        # https://github.com/crowdAI/crowdai/issues/737
        # So we return an empty Hash
        Rails.logger.warn "Found invalid meta key: #{params_meta}.
        Assuming the user meant an empty Hash, or it is corrupt data.
        Reference : https://github.com/crowdAI/crowdai/issues/737 "
        return {}
      end
    end
  end

  def media_fields_present?
    media_large        = params[:media_large]
    media_thumbnail    = params[:media_thumbnail]
    media_content_type = params[:media_content_type]
    raise MediaFieldsIncomplete unless (media_large.present? && media_thumbnail.present? && media_content_type.present?) || (media_large.blank? && media_thumbnail.blank? && media_content_type.blank?)
    return true if media_large.present? && media_thumbnail.present? && media_content_type.present?
    return false if media_large.blank? && media_thumbnail.blank? && media_content_type.blank?
  end

  def get_challenge_round_id(challenge:, params:)
    if params[:challenge_round_id].present?
      round = ChallengeRound.where(
        challenge_id: challenge.id,
        id:           params[:challenge_round_id]).first
      if round.present?
        return round.id
      else
        raise InvalidChallengeRoundID
      end
    end
    round = challenge.current_round
    if round.present?
      return round.id
    else
      raise ChallengeRoundNotOpen
    end
  end

  def challenge_round_open?(challenge)
    return true if challenge.current_round.present?

    round = ChallengeRoundSummary
              .where(challenge_id:    challenge.id,
                     round_status_cd: 'current')
              .where("current_timestamp between start_dttm and end_dttm")
    return false if round.blank?
  end

  def participant_qualified?(challenge, participant)
    return true if challenge.previous_round.nil?

    min_score = challenge.previous_round.minimum_score
    return true if min_score.nil?

    participant_leaderboard = challenge
                          .leaderboards
                          .where(participant_id:     participant.id,
                                 challenge_round_id: challenge.previous_round.id).first
    return false if participant_leaderboard.nil?
    if participant_leaderboard.score >= min_score
      return true
    else
      return false
    end
  end

  def notify_admins(submission)
    Admin::SubmissionNotificationJob.perform_later(submission)
  end

  def grading_params
    case params[:grading_status]
    when 'graded'
      grading_message = params[:grading_message].presence || 'Graded successfully'
      grading_message = params[:grading_message]
      { score:             params[:score],
        score_secondary:   params[:score_secondary],
        grading_status_cd: 'graded',
        grading_message:   grading_message }
    when 'initiated'
      { score:             nil,
        score_secondary:   nil,
        grading_status_cd: 'initiated',
        grading_message:   params[:grading_message] }
    when 'submitted'
      { score:             nil,
        score_secondary:   nil,
        grading_status_cd: 'submitted',
        grading_message:   params[:grading_message] }
    when 'failed'
      raise GradingMessageMissing if params[:grading_message].blank?

      { score:             nil,
        score_secondary:   nil,
        grading_status_cd: 'failed',
        grading_message:   params[:grading_message] }
    else
      raise GradingStatusInvalid
    end
  end

  def parallel_submissions_allowed?(challenge, participant)
    ParallelSubmissionsAllowedService.new(challenge, participant).call
  end
end
