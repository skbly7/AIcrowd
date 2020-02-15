class Blog < ApplicationRecord
  include Markdownable
  include FriendlyId

  friendly_id :participant,
              use: [:slugged]
  belongs_to :participant
  has_many :votes, as: :votable
  validates :posted_at, :participant, presence: true

  def record_page_view
    self.view_count ||= 0
    self.view_count  += 1
    save
  end
end
