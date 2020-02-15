class BaseLeaderboard < ApplicationRecord
  include PolymorphicSubmitter
  belongs_to :challenge
  belongs_to :challenge_round

  as_enum :leaderboard_type,
          [:leaderboard, :ongoing, :previous, :previous_ongoing],
          map: :string

  def self.morph_submitter!(from:, to:, challenge_id:)
    raise ArgumentError unless challenge_id && from && to

    all.where(
      challenge_id: challenge_id,
      submitter:    from
    ).update_all(
      submitter_type: to.class.name,
      submitter_id:   to.id
    )
  end
end
