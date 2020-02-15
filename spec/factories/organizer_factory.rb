FactoryBot.define do
  factory :organizer, class: 'Organizer' do
    organizer { FFaker::Lorem.sentence(3) }
    address { FFaker::Lorem.sentence(3) }
    tagline { "Coke is it" }
    description { FFaker::Lorem.sentence(20) }
    approved { true }
    clef_organizer { false }

    trait :unapproved do
      approved { false }
    end

    trait :clef do
      clef_organizer { true }
    end

    trait :second_organizer do
      organizer { FFaker::Lorem.sentence(3) }
    end

    trait :invalid do
      organizer { nil }
    end
  end
end
