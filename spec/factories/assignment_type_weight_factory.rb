FactoryBot.define do
  factory :assignment_type_weight do
    association :assignment_type
    association :student, factory: :user
    weight 2
  end
end
