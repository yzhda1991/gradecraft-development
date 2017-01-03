FactoryGirl.define do
  factory :course_membership do
    association :course
    association :user
    role :observer

    trait :student do
      role :student
    end

    trait :staff do
      role :gsi
    end

    trait :professor do
      role :professor
    end

    trait :admin do
      role :admin
    end

    trait :audited do
      auditing true
    end
  end
end
