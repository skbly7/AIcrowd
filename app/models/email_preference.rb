class EmailPreference < ApplicationRecord
  belongs_to :participant
  after_initialize :set_defaults, unless: :persisted?

  as_enum :email_frequency, [:every, :daily, :weekly],
          map: :string

  def set_defaults
    # NATE: I don't like the default of true but this is only to make the tests pass and should
    # not occur in production since the email_preference is built after a user is created.
    self.newsletter          = participant ? participant.agreed_to_marketing : true
    self.challenges_followed = true
    self.mentions            = true
    self.email_frequency     = :daily
  end
end
