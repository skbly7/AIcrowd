class Team < ApplicationRecord
  belongs_to :challenge, inverse_of: :teams

  has_many :team_participants, inverse_of: :team, dependent: :destroy
  has_many :team_participants_organizer, -> { role_organizers }, class_name: 'TeamParticipant'

  has_many :team_invitations, inverse_of: :team, dependent: :destroy
  has_many :team_invitations_pending, -> { status_pendings }, class_name: 'TeamInvitation'

  has_many :participants, through: :team_participants, inverse_of: :teams

  scope :for_challenge, ->(challenge) { where(challenge_id: challenge.id) }
  scope :allowing_invitations, -> { where(invitations_allowed: true) }
  scope :with_at_least_n_participants, lambda { |n|
    where(id:
              Team.joins(:team_participants)
        .group(Team.arel_table[:id])
        .having(TeamParticipant.arel_table[:id].count.gteq(n))
        .select(Team.arel_table[:id])
         )
  }
  scope :concrete, -> { with_at_least_n_participants(2) }

  validates :name, uniqueness: { scope: :challenge_id } # case-insensitive because name is a citext
  validates :name, length: { in: 2...256 }
  validates :name,
            format: { with:    /(?=.*[a-zA-Z])/,
                      message: 'must have at least one letter' }
  validates :name,
            format: { with:    /\A[a-zA-Z0-9.\-_{}\[\]]+\z/,
                      message: 'may only contain basic letters, numbers, and any of -_.{}[]' }

  def to_param
    name
  end

  def invitations_left
    challenge.max_team_participants - team_participants.size - team_invitations.status_pendings.size
  end

  def invitations_left_clamped
    [invitations_left, 0].max
  end

  def full?
    num_members = team_participants.size
    num_pending = team_invitations_pending.size
    num_members + num_pending >= challenge.max_team_participants
  end

  def concrete?
    team_participants.size >= 2
  end

  def organized_by?(participant)
    participant && team_participants_organizer.exists?(participant_id: participant.id)
  end
end
