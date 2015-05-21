FactoryGirl.define do
  factory :challenge do
    association :course
    name { Faker::Lorem.word }
    point_total { rand(200) + 100 }
  end
end
