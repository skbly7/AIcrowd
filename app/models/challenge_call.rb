class ChallengeCall < ApplicationRecord
  include FriendlyId
  include Markdownable

  friendly_id :title, use: [:slugged, :finders, :history]
  has_many :challenge_call_responses
  belongs_to :organizer

  def should_generate_new_friendly_id?
    title_changed?
  end

  def call_closed?
    closing_date.present? && closing_date < Time.now.utc
  end
end
