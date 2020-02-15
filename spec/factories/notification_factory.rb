FactoryBot.define do
  factory :notification do
    participant
    notification_type { "leaderboard" }
    association :notifiable, factory: :base_leaderboard

    read_at { nil }
    is_new { true }

    trait :touched do
      is_new { false }
    end

    trait :read do
      is_new { false }
      read_at { 1.day.ago }
    end
  end
end
