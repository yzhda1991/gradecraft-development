FactoryBot.define do
  factory :submission do
    association :assignment
    association :course
    association :student, factory: :user
    text_comment { "needs a link, file, or text comment to be valid" }
    submitted_at { Faker::Date.backward(14) }

    factory :group_submission do
      association :group
      student { nil }
    end

    factory :submission_with_submission_files do
      submission_files { create_list(:present_submission_file, 2) }
    end

    factory :graded_submission do
      association :grade, factory: :complete_grade
    end

    factory :submission_with_text_comment do
      text_comment { "needs a link, file, or text comment to be valid" }
    end

    factory :submission_with_link do
      link { Faker::Internet.url }
    end

    factory :submission_with_present_file do
      submission_files { create_list(:present_submission_file, 2) }
    end

    factory :submission_with_missing_file do
      submission_files { create_list(:missing_submission_file, 2) }
    end

    factory :submission_with_text_comment_only do
      text_comment {"some cool stuff happened" }
      link { nil }
      submission_files { [] }
    end

    factory :submission_with_link_only do
      text_comment {"some cool stuff happened" }
      link { nil }
      submission_files { [] }
    end

    factory :submission_with_files_only do
      text_comment { nil }
      link { nil }
      submission_files { create_list(:present_submission_file, 2) }
    end

    factory :full_submission do
      text_comment { "Something wicked this way comes" }
      link { Faker::Internet.url }
      submission_files { create_list(:present_submission_file, 2) }
    end

    factory :empty_submission do
      text_comment { nil }
      link { nil }
      submission_files { create_list(:missing_submission_file, 2) }
    end

    factory :draft_submission do
      text_comment_draft { "Dear professor, " }
      submitted_at { nil }
    end
  end
end
