FactoryGirl.define do
  factory :level_badge do
    association :level
    association :badge
  end
end
