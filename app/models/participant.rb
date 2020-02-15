class Participant < ApplicationRecord
  include FriendlyId
  include ApiKey
  include Countries

  friendly_id :name, use: [:slugged, :finders, :history]
  before_save :set_api_key
  before_save { self.email = email.downcase }
  before_save :process_urls
  after_create :set_email_preferences
  after_save :refresh_materialized_view
  after_save :publish_to_prometheus
  mount_uploader :image_file, ImageUploader
  validates :image_file, file_size: { less_than: 5.megabytes }

  devise :confirmable,
         :database_authenticatable,
         :lockable,
         :recoverable,
         :registerable,
         :rememberable,
         :validatable,
         :omniauthable, omniauth_providers: %i[github oauth2_generic]

  default_scope { order('name ASC') }
  belongs_to :organizer, optional: true
  has_many :submissions, dependent: :nullify
  has_many :votes, dependent: :destroy
  has_many :blogs, dependent: :nullify
  has_many :challenge_participants, dependent: :destroy
  has_many :leaderboards, class_name: 'Leaderboard', as: :submitter
  has_many :ongoing_leaderboards, class_name: 'OngoingLeaderboard', as: :submitter
  has_many :base_leaderboards, as: :submitter, dependent: :nullify
  has_many :participant_challenges,
           class_name: 'ParticipantChallenge'
  has_many :challenge_registrations,
           class_name: 'ChallengeRegistration'
  has_many :participant_challenge_counts,
           class_name: 'ParticipantChallengeCount'
  has_many :challenge_organizer_participants,
           class_name: 'ChallengeOrganizerParticipant'
  has_many :challenges,
           through: :participant_challenges
  has_many :dataset_file_downloads,
           dependent: :destroy
  has_many :task_dataset_file_downloads,
           dependent: :destroy
  has_many :email_preferences,
           dependent: :destroy
  has_many :email_preferences_tokens,
           dependent: :destroy
  has_many :follows,
           dependent: :destroy
  has_many :participant_clef_tasks,
           dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :access_grants,
           class_name:  "Doorkeeper::AccessGrant",
           foreign_key: :resource_owner_id,
           dependent:   :destroy
  has_many :access_tokens,
           class_name:  "Doorkeeper::AccessToken",
           foreign_key: :resource_owner_id,
           dependent:   :destroy

  has_many :team_participants, inverse_of: :participant
  has_many :teams, through: :team_participants, inverse_of: :participants
  has_many :concrete_teams, -> { concrete }, through: :team_participants, source: :team, inverse_of: :participants
  has_many :invitor_team_invitations, class_name: 'TeamInvitation', foreign_key: :invitor_id, inverse_of: :invitor
  has_many :invitee_team_invitations, class_name: 'TeamInvitation', foreign_key: :invitee_id, inverse_of: :invitee_participant, foreign_type: 'Participant'
  has_many :invitor_email_invitations, class_name: 'EmailInvitation', foreign_key: :invitor_id, inverse_of: :invitor
  has_many :claimant_email_invitations, class_name: 'EmailInvitation', foreign_key: :claimant_id, inverse_of: :claimant

  validates :email,
            presence:              true,
            'valid_email_2/email': true,
            uniqueness:            { case_sensitive: false }

  validates :website, url: { allow_blank: true }
  validates :github, url: { allow_blank: true }
  validates :linkedin, url: { allow_blank: true }
  validates :twitter, url: { allow_blank: true }
  validates :name,
            format:     {
              with:    /\A(?=.*[a-zA-Z])[a-zA-Z0-9.\-_{}\[\]]+\z/,
              message: 'username can contain numbers and these characters -_.{}[] and atleast one letter'
            },
            length:     { in: 2...256 },
            uniqueness: { case_sensitive: false }
  validates :affiliation,
            length:      { in: 2...100 },
            allow_blank: true
  validates :country_cd,
            inclusion: { in: ISO3166::Country.codes }, allow_blank: true
  validates :address,
            length:      { in: 10...255 },
            allow_blank: true
  validates :first_name,
            length:      { in: 2...100 },
            allow_blank: true
  validates :last_name,
            length:      { in: 2...100 },
            allow_blank: true

  def reserved_userhandle
    return unless name

    errors.add(:name, 'is reserved for CrowdAI users.  Please log in via CrowdAI to claim this user handle.') if (provider != 'crowdai') && ReservedUserhandle.where(name: name.downcase).exists?
  end

  def disable_account(reason)
    update(
      account_disabled:        true,
      account_disabled_reason: reason,
      account_disabled_dttm:   Time.now)
  end

  def enable_account
    update(
      account_disabled:        false,
      account_disabled_reason: nil,
      account_disabled_dttm:   nil)
  end

  def active_for_authentication?
    super && account_disabled == false
  end

  def inactive_message
    'Your account has been disabled. Please contact us at help@aicrowd.com' if account_disabled
  end

  def admin?
    admin
  end

  def online?
    updated_at > 10.minutes.ago
  end

  def avatar
    image.try(:image)
  end

  def avatar_medium_url
    if image.present?
      image.image.url(:medium)
    else
      "//#{ENV['DOMAIN_NAME']}/assets/image_not_found.png"
    end
  end

  def image_url
    image_url = if image_file.file.present?
                  image_file.url
                else
                  'users/user-avatar-default.svg'
                end
  end

  def process_urls
    ['website', 'github', 'linkedin', 'twitter'].each do |url_field|
      format_url(url_field)
    end
  end

  def format_url(url_field)
    if send(url_field).present?
      send("#{url_field}=", "http://#{send(url_field)}") unless send(url_field).include?("http://") || send(url_field).include?("https://")
    end
  end

  def after_confirmation
    super
    AddToMailChimpListJob.perform_later(id)
  end

  def set_email_preferences
    email_preferences.create!
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  # TODO: Investigate how to get rid of this hack without causing issues
  def self.find(args)
    super
  rescue StandardError
    nil
  end

  def refresh_materialized_view
    RefreshChallengeOrganizerParticipantViewJob.perform_later if saved_change_to_attribute?(:organizer_id)
  end

  def publish_to_prometheus
    Prometheus::ParticipantCounterService.new.call
  end

  def self.sanitize_userhandle(userhandle)
    userhandle.to_ascii
      .tr("@", "a")
      .gsub("&", "and")
      .delete('#')
      .delete('*')
      .gsub(/[\,\.\'\;\-\=]/, "")
      .gsub(/[\(\)]/, "_")
      .tr(' ', "_")
  end

  def self.from_omniauth(auth)
    raw_info  = auth.raw_info || (auth.extra&.raw_info&.participant)
    email     = auth.info.email || raw_info.email
    username  = auth.info.name || raw_info.name
    username  = username.gsub(/\s+/, '_').downcase
    username  = sanitize_userhandle(username)
    image_url = auth.info.image ||
      raw_info.image ||
      (raw_info.image_file&.url)
    provider = auth.provider
    provider = 'crowdai' if provider == 'oauth2_generic'
    where(email: email).first_or_create do |user|
      user.email    = email
      user.password = Devise.friendly_token[0, 20]
      user.name     = username
      user.provider = provider
      puts "EMAIL: #{email} name: #{username} provider: #{provider}"
      user.remote_image_file_url = image_url if image_url
      ### NATE: we want to skip the notification but leave the user unconfirmed
      ### which will allow us to force a password reset on first login
      user.skip_confirmation_notification!
    end
  end

  def current_participation_terms
    ParticipationTerms.current_terms
  end

  def current_participation_terms_version
    current_participation_terms&.version
  end

  def has_accepted_participation_terms?
    return if participation_terms_accepted_version != current_participation_terms_version
    return unless participation_terms_accepted_date

    return true
  end
end
