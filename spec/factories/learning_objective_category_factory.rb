FactoryBot.define do
  factory :learning_objective_category do
    association :course

    name { Faker::Commerce.department(5) }
  end
end
