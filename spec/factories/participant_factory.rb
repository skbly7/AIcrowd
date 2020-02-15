FactoryBot.define do
  factory :participant, class: Participant do
    name                                 { FFaker::Name.unique.first_name }
    email                                { FFaker::Internet.unique.email }
    password                             { 'password12' }
    password_confirmation                { 'password12' }
    confirmed_at                         { Time.current }
    api_key                              { SecureRandom.hex }
    affiliation                          { FFaker::Company.name }
    address                              { FFaker::Address.street_address }
    city                                 { FFaker::Address.city }
    country_cd                           { FFaker::Address.country_code }
    organizer                            { nil }
    timezone                             { 'GMT' }
    agreed_to_terms_of_use_and_privacy   { true }
    participation_terms_accepted_date    { Time.current }
    participation_terms_accepted_version { 1 }

    after :create do
      create(:participation_terms) if ParticipationTerms.current_terms.nil?
    end

    trait :admin do
      admin { true }
    end

    trait :organizer do
      organizer { FactoryBot.create(:organizer) }
    end

    trait :clef_organizer do
      organizer { FactoryBot.create(:organizer, :clef) }
    end

    trait :invalid do
      name { nil }
    end

    trait :every_email do
      after :create do |participant|
        participant.email_preferences.first.update(email_frequency: :every)
      end
    end

    trait :daily do
      after :create do |participant|
        participant.email_preferences.first.update(email_frequency: :daily)
      end
    end

    trait :weekly do
      after :create do |participant|
        participant.email_preferences.first.update(email_frequency: :weekly)
      end
    end

    trait :newsletter_true do
      after :create do |participant|
        participant.email_preferences.first.update_columns(newsletter: true)
      end
    end

    trait :newsletter_false do
      after :create do |participant|
        participant.email_preferences.first.update_columns(newsletter: false)
      end
    end

    trait :clef_incomplete do
      address nil
    end

    trait :clef_complete do
      address     { FFaker::Address.street_address }
      affiliation { FFaker::Company.name }
      first_name  { FFaker::Name.first_name }
      last_name   { FFaker::Name.last_name }
      country_cd  { FFaker::Address.country_code }
      city        { FFaker::Address.country }
    end

    trait :with_email_preferences_token do
      after :create do |participant|
        create(:email_preferences_token, participant: participant)
      end
    end
  end
end
