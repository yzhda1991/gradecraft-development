FactoryGirl.define do
  factory :submission do
    association :assignment
    text_comment "needs a link, file, or text comment to be valid"

    factory :graded_submission do
      association :grade, factory: :released_grade
    end
  end
end

