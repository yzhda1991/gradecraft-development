FactoryGirl.define do
  factory :learning_objective_observed_outcome do
    association :learning_objective_level

    assessed_at { Faker::Date.backward(60) }
    comments { Faker::Hipster.sentence }

    factory :student_visible_observed_outcome do
      association :grade, factory: :student_visible_grade
    end
  end
end
