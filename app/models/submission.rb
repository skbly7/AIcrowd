class Submission < ApplicationRecord
  include Markdownable
  before_validation :generate_short_url

  belongs_to :challenge, counter_cache: true
  belongs_to :participant, optional: true
  belongs_to :challenge_round, optional: true

  with_options dependent: :destroy do
    has_many :submission_files
    has_many :submission_grades
  end
  accepts_nested_attributes_for :submission_files,
                                reject_if:     ->(f) { f[:submission_file_s3_key].blank? },
                                allow_destroy: true
  has_many :votes, as: :votable

  as_enum :grading_status,
          [:ready, :submitted, :initiated, :graded, :failed], map: :string

  validates :challenge_id, presence: true
  validates :grading_status, presence: true
  validate :clef_validations

  delegate :name, :email, to: :participant, allow_nil: true

  def clef_validations
    return true
    return true unless challenge.organizer.clef?

    if clef_method_description.length < 5
      errors.add(:clef_method_description,
                 'Must be at least 5 characters.')
    end
  end

  after_create do
    if challenge_round_id.blank?
      rnd = challenge
        .challenge_rounds
        .where(
          'start_dttm <= ? and end_dttm >= ?',
          created_at, created_at).first
      rnd = challenge.challenge_rounds.last if rnd.blank?
      if rnd.present? && rnd.end_dttm.present?
        update(challenge_round_id: rnd.id)
        update(post_challenge: true) if created_at > rnd.end_dttm
      else
        raise ChallengeRoundIDMissing
      end
    end
  end

  after_save do
    # !self.meta&.dig('final_avg') is added to prevent infinite loops in New Leaderboard Calculation
    if grading_status_cd == 'graded' && !meta&.dig('private_ignore-leaderboard-job-computation')
      Rails.logger.info "[Submission Model] Starting the Leaderboard Update Job! (onsave)"
      CalculateLeaderboardJob
        .perform_later(challenge_round_id: challenge_round_id)
    end
    Prometheus::SubmissionCounterService.new(submission_id: id).call
  end

  after_destroy do
    CalculateLeaderboardJob
      .perform_later(challenge_round_id: challenge_round_id)
  end

  def team
    participant&.teams&.for_challenge(challenge)&.first
  end

  def ready?
    grading_status == :ready
  end

  def submitted?
    grading_status == :submitted
  end

  def graded?
    grading_status == :graded
  end

  def failed?
    grading_status == :failed
  end

  def initiated?
    grading_status == :initiated
  end

  def other_scores_array
    other_scores = []
    challenge.other_scores_fieldnames_array.each do |fname|
      if (meta&.is_a? Hash) && (meta&.key? fname)
        other_scores << (meta[fname].nil? ? 0.0 : meta[fname])
      end
    end
    # Always return an array of size 5
    other_scores + [0.0] * (5 - other_scores.size)
  end

  CLEF_RETRIEVAL_TYPES = {
    'Visual'                     => :visual,
    'Textual'                    => :textual,
    'Mixed (Textual and Visual)' => :mixed,
    'Not applicable'             => :not_applicable
  }.freeze

  CLEF_RUN_TYPES = {
    'Automatic'                          => :automatic,
    'Feedback or / and Human Assistance' => :feedback,
    'Manual'                             => :manual
  }.freeze

  def as_json(options = {})
    super(
      only:    [:id, :participant_id, :score, :score_secondary, :grading_status_cd, :grading_message, :post_challenge, :media_content_type, :created_at, :updated_at, :meta],
      include: { participant: { only: [:name] } }
    )
  end

  private

  def generate_short_url
    if short_url.blank?
      short_url = nil
      begin
        short_url = SecureRandom.hex(6)
      end while (Submission.exists?(short_url: short_url))
      self.short_url = short_url
    end
  end

  class ChallengeRoundIDMissing < StandardError
    def initialize(msg = 'No Challenge Round ID can be found for this submission')
      super
    end
  end
end
