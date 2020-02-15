class TeamParticipant < ApplicationRecord
  ROLES = [:member, :organizer].freeze

  belongs_to :team, inverse_of: :team_participants
  belongs_to :participant, inverse_of: :teams

  as_enum :role, ROLES, map: :string, source: :role, prefix: true

  validates :role, inclusion: { in: ROLES }
end
