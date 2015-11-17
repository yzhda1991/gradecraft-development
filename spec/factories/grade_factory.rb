FactoryGirl.define do
  factory :grade do
    association :assignment 
    association :student, factory: :user

    factory :scored_grade do
      raw_score { Faker::Number.number(5) }
      status "Released"
    end

    # minimal conditions when a grade has been graded but not visible to students
    factory :unreleased_grade do
      raw_score { Faker::Number.number(5) }
      status 'Graded'
      after(:create) do |grade|
        grade.assignment.update(release_necessary: true)
      end
    end

    factory :in_progress_grade do
      raw_score { Faker::Number.number(5) }
      score { raw_score }
      status 'In Progress'
    end
  end
end
