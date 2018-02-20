FactoryGirl.define do
  factory :assignment_type do
    name { Faker::Lorem.word }
    course { create(:course) }

    trait :has_max_points do
      has_max_points true
      max_points { Faker::Number.number(5) }
    end

    trait :attendance do
      attendance true
      name "Attendance"
    end
  end
end
