FactoryBot.define do
  factory :level do
    name { Faker::Lorem.word }
    points { Faker::Number.number(4) }
    association :criterion
  end
end
