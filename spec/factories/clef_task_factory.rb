FactoryBot.define do
  factory :clef_task, class: 'ClefTask' do
    association :organizer, :clef
    task { FFaker::Lorem.sentence(3) }

    trait :with_eua do
      eua_file { File.open("#{Rails.root}/spec/support/files/test_pdf_file.pdf", 'r') }
    end

    trait :life_clef do
      task_dataset_files do
        [build(:task_dataset_file, title: 'file 1'),
         build(:task_dataset_file, title: 'file 2'),
         build(:task_dataset_file, title: 'file 3')]
      end
    end

    trait :image_clef do
      task_dataset_files do
        [build(:task_dataset_file, title: 'file 1'),
         build(:task_dataset_file, title: 'file 2'),
         build(:task_dataset_file, title: 'file 3')]
      end
      eua_file { File.open("#{Rails.root}/spec/support/files/test_pdf_file.pdf", 'r') }
    end

    trait :invalid do
      task { nil }
    end
  end
end
