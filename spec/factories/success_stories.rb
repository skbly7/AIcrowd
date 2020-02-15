FactoryBot.define do
  factory :success_story do
    title { FFaker::Lorem.unique.sentence(3) }
    slug { FFaker::Lorem.unique.sentence(1) }
    published { true }
    posted_at { Time.now }
  end
end
