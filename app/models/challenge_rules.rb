class ChallengeRules < ApplicationRecord
  include Markdownable
  belongs_to :challenge

  before_create do
    self.version = if challenge.current_challenge_rules
                     challenge.current_challenge_rules.version + 1
                   else
                     1
                   end
  end
end
