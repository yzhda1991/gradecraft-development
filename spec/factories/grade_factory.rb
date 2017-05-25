FactoryGirl.define do
  factory :grade do
    association :assignment
    association :student, factory: :user

    factory :released_grade do
      raw_points { Faker::Number.number(5) }
      status "Released"
    end

    # minimal conditions when a grade has been graded but not visible to students
    factory :unreleased_grade do
      raw_points { Faker::Number.number(5) }
      status "In Progress"
    end

    factory :in_progress_grade do
      raw_points { Faker::Number.number(5) }
      score { raw_points }
      status "In Progress"
    end
  end
end
