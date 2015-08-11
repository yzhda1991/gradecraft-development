FactoryGirl.define do
  factory :announcement do
    association :course
    association :author, factory: :user
  end
end
