class Challenge < ApplicationRecord
  include FriendlyId
  include Markdownable

  friendly_id :challenge,
              use: %i[slugged finders history]

  belongs_to :organizer
  belongs_to :clef_task, optional: true
  has_many :dataset_files,
           dependent: :destroy
  mount_uploader :image_file, ImageUploader

  has_many :submission_file_definitions,
           dependent:  :destroy,
           inverse_of: :challenge
  accepts_nested_attributes_for :submission_file_definitions,
                                reject_if:     :all_blank,
                                allow_destroy: true
  has_many :challenge_partners, dependent: :destroy
  accepts_nested_attributes_for :challenge_partners,
                                reject_if:     :all_blank,
                                allow_destroy: true

  has_many :challenge_rules, -> { order 'version desc' }, dependent: :destroy, class_name: 'ChallengeRules'
  accepts_nested_attributes_for :challenge_rules,
                                reject_if:     :all_blank,
                                allow_destroy: true

  has_many :challenge_participants, dependent: :destroy

  has_many :submissions, dependent: :destroy
  has_many :leaderboards,
           class_name: 'Leaderboard'
  has_many :ongoing_leaderboards,
           class_name: 'OngoingLeaderboard'
  has_many :participant_challenges,
           class_name: 'ParticipantChallenge'
  has_many :participant_challenge_counts,
           class_name: 'ParticipantChallengeCount'
  has_many :challenge_registrations,
           class_name: 'ChallengeRegistration'
  has_many :challenge_organizer_participants,
           class_name: 'ChallengeOrganizerParticipant'

  has_many :votes, as: :votable
  has_many :follows, as: :followable
  has_many :challenge_rounds,
           dependent:  :destroy,
           inverse_of: :challenge
  accepts_nested_attributes_for :challenge_rounds,
                                reject_if:     :all_blank,
                                allow_destroy: true
  has_many :challenge_round_summaries
  has_many :invitations, dependent: :destroy
  accepts_nested_attributes_for :invitations,
                                reject_if:     :all_blank,
                                allow_destroy: true

  has_many :teams, inverse_of: :challenge

  as_enum :status,
          %i[draft running completed starting_soon],
          map: :string

  validates :status, presence: true
  validates :challenge, presence: true
  validates :challenge_client_name, uniqueness: true
  validates :challenge_client_name,
            format: { with: /\A[a-zA-Z0-9]/ }
  validates :challenge_client_name, presence: true

  validate :other_scores_fieldnames_max

  default_scope do
    order("challenges.featured_sequence,
            CASE challenges.status_cd
              WHEN 'running' THEN 1
              WHEN 'starting_soon' THEN 2
              WHEN 'completed' THEN 3
              WHEN 'draft' THEN 4
              ELSE 5
            END, challenges.participant_count DESC")
  end

  after_initialize :set_defaults
  after_create :create_discourse_category
  after_update :update_discourse_category

  def set_defaults
    if new_record?
      self.submission_license    ||= 'Please upload your submissions and include a detailed description of the methodology, techniques and insights leveraged with this submission. After the end of the challenge, these comments will be made public, and the submitted code and models will be freely available to other AIcrowd participants. All submitted content will be licensed under Creative Commons (CC).'
      self.challenge_client_name ||= "challenge_#{SecureRandom.hex}"
      self.featured_sequence       = Challenge.count + 1
    end
  end

  def create_discourse_category
    return if Rails.env.development? || Rails.env.test?

    Discourse::CreateCategoryService.new(challenge: self).call
  end

  def update_discourse_category
    return if Rails.env.development? || Rails.env.test?

    Discourse::UpdateCategoryService.new(challenge: self).call
  end

  def record_page_view
    self.page_views ||= 0
    self.page_views  += 1
    save
  end

  def status_formatted
    'Starting soon' if status == :starting_soon
    status.capitalize
  end

  def start_dttm
    @start_dttm ||= begin
                      return nil if current_round.nil? || current_round.start_dttm.nil?

                      current_round.start_dttm
                    end
  end

  def end_dttm
    @end_dttm ||= begin
                    return nil if current_round.nil? || current_round.end_dttm.nil?

                    current_round.end_dttm
                  end
  end

  def submissions_remaining(participant_id)
    SubmissionsRemainingQuery.new(challenge: self, participant_id: participant_id).call
  end

  def current_round
    @current_round ||= challenge_round_summaries.where(round_status_cd: 'current').first
  end

  def previous_round
    return nil if current_round.row_num == 1

    challenge_round_summaries.where(row_num: current_round.row_num - 1).first
  end

  def round_open?
    @round_open ||= current_round.present?
  end

  def should_generate_new_friendly_id?
    challenge_changed?
  end

  def post_challenge_submissions?
    post_challenge_submissions
  end

  def current_challenge_rules
    ChallengeRules.where(challenge_id: id).order('version DESC').first
  end

  def current_challenge_rules_version
    current_challenge_rules&.version
  end

  def has_accepted_challenge_rules?(participant)
    return false unless participant

    cp = ChallengeParticipant.where(challenge_id: id, participant_id: participant.id).first
    return false unless cp
    return false if cp.challenge_rules_accepted_version != current_challenge_rules_version
    return false unless cp.challenge_rules_accepted_date

    true
  end

  def other_scores_fieldnames_max
    errors.add(:other_scores_fieldnames, 'A max of 5 other scores Fieldnames are allowed') if other_scores_fieldnames && (other_scores_fieldnames.count(',') > 4)
  end

  def teams_frozen?
    if status == :completed
      # status set
      true
    else
      ended_at = team_freeze_time || end_dttm
      if ended_at && Time.zone.now > ended_at
        # there is an end date and we are past it
        true
      else
        false
      end
    end
  end

  def other_scores_fieldnames_array
    arr = other_scores_fieldnames
    arr&.split(',')&.map(&:strip) || []
  end
end
