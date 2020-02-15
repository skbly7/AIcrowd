class SuccessStory < ApplicationRecord
  include FriendlyId

  friendly_id :challenge,
              use: [:slugged]
  mount_uploader :image_file, ImageUploader
  validates :posted_at, presence: true
end
