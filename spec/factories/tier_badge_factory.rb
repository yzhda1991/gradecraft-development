FactoryGirl.define do
  factory :tier_badge do
    association :tier
    association :badge
  end
end
