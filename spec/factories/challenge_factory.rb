FactoryGirl.define do
  factory :challenge do
    association :course
    name { Faker::Lorem.word }
    release_necessary false
    full_points { rand(200) + 100 }
    visible true
    accepts_submissions true
  end
end
