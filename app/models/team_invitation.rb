class TeamInvitation < ApplicationRecord
  STATUSES = [
    :pending,  # invitation sending/sent, but no action taken yet
    :accepted, # invitee accepted and became a team member
    :declined, # invitee declined and did not become a team member
    :canceled # the invitee will not become a member because the organizer rescinded the invitation
  ].freeze

  after_initialize :init_uuid, if: :new_record?

  belongs_to :team, inverse_of: :team_invitations
  belongs_to :invitor, class_name: 'Participant', inverse_of: :invitor_team_invitations
  belongs_to :invitee, polymorphic: true
  has_one :self_ref, class_name: "::#{name}", foreign_key: :id
  has_one :invitee_participant, through: :self_ref, source: :invitee, source_type: 'Participant', inverse_of: :invitee_team_invitations
  has_one :invitee_email_invitation, through: :self_ref, source: :invitee, source_type: 'EmailInvitation', inverse_of: :invitee_team_invitation

  scope :participant_invitees, -> { Participant.where(id: where(invitee_type: 'Participant').select(:invitee_id)) }
  scope :email_invitees, -> { EmailInvitation.where(id: where(invitee_type: 'EmailInvitation').select(:invitee_id)) }

  as_enum :status, STATUSES, map: :string, source: :status, prefix: true

  validates :status, inclusion: { in: STATUSES }
  validates :uuid, uniqueness: true

  def invitee_name_or_email
    case invitee
    when Participant
      invitee.name
    when EmailInvitation
      invitee.email
    end
  end

  def to_param
    uuid
  end

  def init_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def self.invitees_a
    participant_invitees.to_a + email_invitees.to_a
  end
end
