FactoryGirl.define do
  factory :rubric_grade do
    association :student, factory: :user
    association :assignment
    max_points Faker::Number.number(5)
    metric_name "Well written"
    order Faker::Number.number(2)
  end
end
