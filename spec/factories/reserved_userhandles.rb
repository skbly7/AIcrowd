FactoryBot.define do
  factory :reserved_userhandle do
    name { FFaker::Name.unique.first_name }
  end
end
