FactoryBot.define do
  factory :challenge_rules do
    challenge
    terms { 'terms' }
    terms_markdown { 'terms' }
    has_additional_checkbox { false }
    additional_checkbox_text { false }
    version { 1 }
    additional_checkbox_text_markdown { nil }
  end
end
