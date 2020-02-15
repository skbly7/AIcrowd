FactoryBot.define do
  factory :email_preferences_token, class: EmailPreferencesToken do
    email_preferences_token { SecureRandom.urlsafe_base64(24) }
    token_expiration_dttm   { DateTime.current + 30.days }

    association(:participant)
  end
end
