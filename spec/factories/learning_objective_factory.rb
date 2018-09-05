FactoryBot.define do
  factory :learning_objective do
    association :course
    count_to_achieve { Faker::Number.between(1, 5) }

    name { Faker::Hacker.ingverb }
    description { Faker::Hacker.say_something_smart }

    trait :with_count_to_achieve do
      count_to_achieve { Faker::Number.between(1, 5) }
    end

    trait :with_points_to_completion do
      points_to_completion { 1337 }
    end

    trait :categorized do
      association :category, factory: :learning_objective_category
    end

    trait :with_linked_assignment do
      after(:create) do |lo|
        lo.assignments << create(:assignment)
      end
    end
  end
end
