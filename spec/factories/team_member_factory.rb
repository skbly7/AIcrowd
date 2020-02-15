require 'ffaker'

FactoryBot.define do
  factory :team_member do
    name { FFaker::Name.name }
    title { FFaker::Job.title }
    section { FFaker::Job.title }
    seq { (TeamMember.maximum(:seq) || 0) + 1 }
    participant
  end
end
