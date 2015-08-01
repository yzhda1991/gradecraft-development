FactoryGirl.define do
  factory :task do
    association :assignment
    association :course
  end
end
