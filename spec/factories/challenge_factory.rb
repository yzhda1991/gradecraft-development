FactoryBot.define do
  factory :challenge do
    association :course
    name { Faker::Lorem.word }
    full_points { rand(200) + 100 }
    visible { true }
    accepts_submissions { true }
  end
end
