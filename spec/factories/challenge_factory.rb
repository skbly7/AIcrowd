FactoryBot.define do
  factory :challenge, class: 'Challenge' do
    organizer
    challenge { FFaker::Lorem.unique.sentence(3) }
    challenge_client_name { FFaker::Internet.unique.user_name }
    tagline { FFaker::Lorem.unique.sentence(3) }
    status { :draft }
    description_markdown { "### The description" }
    evaluation_markdown { "# An evaluation" }
    rules_markdown { "Some *rules*" }
    prizes_markdown { "# Prizes are described here." }
    resources_markdown { "# Helpful resources" }
    dataset_description_markdown { "# Dataset description" }
    submission_instructions_markdown { "## Submission instructions" }
    score_title { 'Title_primary' }
    score_secondary_title { 'Title_secondary' }
    license_markdown { '## This is a license' }
    submissions_page { true }
    show_leaderboard { true }
    discussions_visible { true }
    teams_allowed { true }
    max_team_participants { 5 }

    trait :with_rules do
      after(:create) do |challenge|
        create(:challenge_rules, challenge: challenge) if challenge.current_challenge_rules.nil?
      end
    end

    trait :running do
      status { :running }
      dataset_files { [build(:dataset_file)] }
      after(:create) do |challenge|
        FactoryBot.create(:challenge_round, challenge: challenge)
      end
    end

    trait :day do
      status { :running }
      dataset_files { [build(:dataset_file)] }
      after(:create) do |challenge|
        FactoryBot.create(
          :challenge_round,
          challenge:               challenge,
          start_dttm:              challenge.created_at - 2.weeks,
          end_dttm:                challenge.created_at + 3.weeks,
          submission_limit_period: :day)
      end
    end

    trait :week do
      status { :running }
      dataset_files { [build(:dataset_file)] }
      after(:create) do |challenge|
        FactoryBot.create(
          :challenge_round,
          challenge:               challenge,
          start_dttm:              challenge.created_at - 2.weeks,
          end_dttm:                challenge.created_at + 3.weeks,
          submission_limit_period: :week)
      end
    end

    trait :round do
      status { :running }
      dataset_files { [build(:dataset_file)] }
      after(:create) do |challenge|
        FactoryBot.create(
          :challenge_round,
          challenge:               challenge,
          start_dttm:              challenge.created_at - 2.weeks,
          end_dttm:                challenge.created_at + 3.weeks,
          submission_limit_period: :round)
      end
    end

    trait :previous_round do
      status { :running }
      dataset_files { [build(:dataset_file)] }
      after(:create) do |challenge|
        FactoryBot.create(
          :challenge_round,
          :historical,
          challenge:               challenge,
          challenge_round:         'round 1',
          submission_limit:        5,
          submission_limit_period: :round,
          start_dttm:              challenge.created_at - 5.weeks,
          end_dttm:                challenge.created_at - 3.weeks)
        FactoryBot.create(
          :challenge_round,
          challenge:               challenge,
          challenge_round:         'round 2',
          submission_limit:        5,
          submission_limit_period: :round,
          start_dttm:              challenge.created_at - 2.weeks,
          end_dttm:                challenge.created_at + 3.weeks)
      end
    end

    trait :draft do
      status { :draft }
      challenge { FFaker::Lorem.sentence(3) }
    end

    trait :completed do
      status { :completed }
      challenge { FFaker::Lorem.sentence(3) }
      dataset_files { [build(:dataset_file)] }
      after(:create) do |challenge|
        FactoryBot.create(:challenge_round, challenge: challenge)
      end
    end

    trait :starting_soon do
      status { :starting_soon }
      challenge { FFaker::Lorem.sentence(3) }
    end
  end
end
