class EmailInvitation < ApplicationRecord
  after_initialize :init_token, if: :new_record?

  belongs_to :invitor, class_name: 'Participant', inverse_of: :invitor_email_invitations
  belongs_to :clamiant, optional: true, class_name: 'Participant', inverse_of: :claimant_email_invitations
  has_one :invitee_team_invitation, class_name: 'TeamInvitation', inverse_of: :invitee_email_invitation

  before_validation :normalize_token!

  validates :invitor, presence: true
  validates :email, presence: true
  validates :token, presence: true

  def display_token
    Base31.display_token(token, 3, '-')
  end

  def token_eq?(other)
    Base31.eq?(token, other)
  end

  private def normalize_token!
    self.token = Base31.normalize_s(token) if token.is_a?(String)
  end

  private def init_token
    self.token ||= Base31.secure_random_str(9)
  end
end
