FactoryBot.define do
  factory :learning_objective_level do
    association :objective, factory: :learning_objective

    name { Faker::Hacker.noun }
    description { Faker::Hacker::say_something_smart }
    flagged_value { :proficient }

    trait :exceeds_proficiency do
      flagged_value { :exceeds_proficiency }
    end

    trait :proficient do
      flagged_value { :proficient }
    end

    trait :nearing_proficiency do
      flagged_value { :nearing_proficiency }
    end

    trait :not_proficient do
      flagged_value { :not_proficient }
    end
  end
end
