FactoryBot.define do
  factory :assignment_score_level do
    name { Faker::Lorem.word }
    points { Faker::Number.number(5) }
    association :assignment
  end
end
