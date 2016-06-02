FactoryGirl.define do
  factory :challenge do
    association :course
    name { Faker::Lorem.word }
    release_necessary false
    full_points { rand(200) + 100 }
  end
end
