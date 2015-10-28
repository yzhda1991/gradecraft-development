FactoryGirl.define do
  factory :assignment_weight do
    association :course
    association :assignment_type
    association :assignment
    association :student, factory: :user
    weight Faker::Number.number(2)
  end
end
