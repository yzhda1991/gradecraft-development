FactoryGirl.define do
  factory :challenge_score_level do
    name { Faker::Lorem.word }
    value { Faker::Number.number(5) }
    association :challenge
  end
end
