FactoryGirl.define do
  factory :submission do
    association :assignment
    text_comment "needs a link, file, or text comment to be valid"

    factory :graded_submission do
      association :grade, factory: :released_grade
    end

    factory :submission_with_text_comment do
      text_comment "needs a link, file, or text comment to be valid"
    end

    factory :submission_with_link do
      text_comment nil
      link Faker::Internet.url
    end

    factory :submission_with_present_file do
      text_comment nil
      submission_files { create_list(:present_submission_file, 2) }
    end

    factory :submission_with_missing_file do
      text_comment nil
      submission_files { create_list(:missing_submission_file, 2) }
    end

    factory :empty_submission do
      text_comment nil
      link nil
      submission_files { create_list(:missing_submission_file, 2) }
    end
  end
end

