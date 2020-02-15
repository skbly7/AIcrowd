FactoryBot.define do
  factory :challenge_participant, class: 'ChallengeParticipant' do
    accepted_dataset_toc             { true }
    challenge_rules_accepted_date    { Time.current }
    challenge_rules_accepted_version { 1 }

    association(:challenge)
    association(:participant)
  end
end
