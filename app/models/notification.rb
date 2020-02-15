class Notification < ApplicationRecord
  belongs_to :participant
  belongs_to :notifiable, polymorphic: true

  scope :pristine, -> { where(is_new: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :unread, -> { where(read_at: nil) }

  validates :notification_type, presence: true

  NOTIFICATION_TYPE = {
    'Mention'        => :mention,
    'Graded'         => :graded,
    'Grading Failed' => :grading_failed,
    'Leaderboard'    => :leaderboard,
    'Article'        => :article
  }.freeze

  def read?
    read_at.present?
  end
end
