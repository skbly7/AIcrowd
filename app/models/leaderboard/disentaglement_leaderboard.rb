class DisentanglementLeaderboard < ApplicationRecord
  belongs_to :challenge
  belongs_to :challenge_round
  belongs_to :participant, optional: true
end
