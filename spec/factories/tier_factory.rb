FactoryGirl.define do
  factory :tier do
    name Faker::Lorem.word
    points Faker::Number.number(4)
    association :metric
  end
end
