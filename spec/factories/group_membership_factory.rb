FactoryGirl.define do
  factory :group_membership do
    association :group
    association :student, factory: :user
  end
end
