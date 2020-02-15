FactoryBot.define do
  factory :team_participant do
    association(:team)
    association(:participant)
  end
end
