FactoryBot.define do
  factory :team, class: 'Team' do
    association :challenge
    name do
      FFaker::Company.unique.name\
      .tr(' ', '_')
      .gsub(/[^a-zA-Z0-9.\-_{}\[\]]+/, '')
    end

    after :create do |team, evaluator|
      first_participant = evaluator.participants&.first
      if first_participant
        tp = team.team_participants.find_by!(participant_id: first_participant.id)
        tp.update_column(:role, :organizer)
      end
    end
  end

  trait :dotted_name do # normal name with '.a' at the end
    name do
      FFaker::Company.unique.name\
      .tr(' ', '_')
      .gsub(/[^a-zA-Z0-9.\-_{}\[\]]+/, '')
      + '.a'
    end
  end
end
