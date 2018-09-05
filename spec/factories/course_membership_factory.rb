FactoryBot.define do
  factory :course_membership do
    association :course
    association :user

    instructor_of_record { false }
    role { :observer }

    trait :student do
      instructor_of_record { false }
      role { :student }
    end

    trait :staff do
      instructor_of_record { true }
      role { :gsi }
    end

    trait :professor do
      instructor_of_record { true }
      role { :professor }
    end

    trait :admin do
      instructor_of_record { true }
      role { :admin }
    end

    trait :auditing do
      auditing { true }
    end
  end
end
