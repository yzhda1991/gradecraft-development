FactoryGirl.define do
  factory :learning_objective_observed_outcome do
    association :learning_objective_level

    assessed_at { Faker::Date.backward(60) }
    comments { Faker::Hipster.sentence }

    factory :learning_objective_observed_outcome_grade do
      transient do
        student_visible_grade true
      end

      grade do
        create :grade, student_visible: student_visible_grade
      end
    end
  end
end
