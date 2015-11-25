FactoryGirl.define do
  factory :assignment_weight do
    association :assignment
    association :student, factory: :user
    weight 2
  end
end
