FactoryBot.define do
  factory :group_membership do
    association :group
    association :course, factory: :course
    association :student, factory: :user
  end
end
