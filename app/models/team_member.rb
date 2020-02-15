class TeamMember < ApplicationRecord
  validates :name, presence: true
  validates :title, presence: true
  validates :section, presence: true
  validates :seq, presence: true, uniqueness: true

  belongs_to :participant
end
