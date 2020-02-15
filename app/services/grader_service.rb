class GraderService
  include HTTParty
  debug_output $stdout
  base_uri ENV["GRADER"]

  # https://grader.crowdai.org:10000/
  # GraderService.new(submission_id: 358).call

  def initialize(submission_id:)
    @submission           = Submission.find(submission_id)
    challenge             = @submission.challenge
    participant           = @submission.participant
    challenge_participant = challenge
      .challenge_participants
      .find_by(participant_id: participant.id)

    if challenge_participant.blank? || !challenge_participant.accepted_dataset_toc
      Submission.update(
        @submission.id,
        grading_status:  'failed',
        grading_message: 'Invalid Submission. Have you registered for this challenge and agreed to the participantion terms?')
      return false
    end
  end

  def call
    @body = api_query
    if @body
      response = call_grader
      evaluate_response(
        submission_id: @submission.id,
        response:      response)
    end
  end

  def call_grader
    response = self.class.post('/enqueue_grading_job', body: @body)
    return response
  rescue StandardError => e
    Submission.update(
      @submission.id,
      grading_status:  'failed',
      grading_message: e.message)
    raise e
  end

  def preflight_checked?(challenge, participant, submission_key)
    if participant.api_key.present? && challenge.grader_identifier.present? && challenge.challenge_client_name.present? &&
        submission_key.present?
      return true
    else
      return false
    end
  end

  def evaluate_response(submission_id:, response:)
    # {"response_type"=>"AIcrowd.Event.SUCCESS", "message"=>"Successfully enqueued 1 Job", "data"=>{}}
    if response.code == 200
      resp = JSON(response.body)
      Submission.update(
        submission_id,
        grading_status:  'submitted',
        grading_message: resp["message"])
    else
      Submission.update(
        submission_id,
        grading_status:  'failed',
        grading_message: 'Grading process system error, please contact AIcrowd administrators.')
    end
  end

  private

  def api_query
    challenge      = @submission.challenge
    participant    = @submission.participant
    submission_key = get_submission_key
    team_id        = participant.teams.where(challenge: challenge).first&.id || 'undefined'

    if preflight_checked?(challenge, participant, submission_key)
      return body = {
        response_channel:      "na",
        session_token:         "na",
        api_key:               participant.api_key,
        grader_id:             challenge.grader_identifier, # CLEFChallenges
        challenge_client_name: challenge.challenge_client_name,
        function_name:         "grade_submission",
        data:                  [{ "file_key": submission_key, submission_id: @submission.id, participant_id: participant.id, challenge_round_id: @submission.challenge_round_id, team_id: team_id }],
        dry_run:               'false',
        parallel:              'false',
        enqueue_only:          'true',
        grader_api_key:        ENV['CROWDAI_API_KEY']
      }
    else
      Submission.update(
        @submission.id,
        grading_status:  'failed',
        grading_message: 'Grading process system error, please contact AIcrowd administrators.')
      return false
    end
  end

  def get_submission_key
    key = @submission.submission_files.first.submission_file_s3_key
  end
end
