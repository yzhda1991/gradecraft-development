FactoryGirl.define do
  factory :criterion_grade do
    association :student, factory: :user
    association :assignment
    max_points Faker::Number.number(5)
    criterion_name "Well written"
    order Faker::Number.number(2)
  end
end
