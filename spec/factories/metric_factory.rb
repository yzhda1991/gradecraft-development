FactoryGirl.define do
  factory :criterion do
    max_points { Faker::Number.number(5) }
    name { Faker::Lorem.word }
    sequence(:order)
  end
end
