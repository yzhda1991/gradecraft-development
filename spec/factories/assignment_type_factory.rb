FactoryGirl.define do
  factory :assignment_type do
    name { Faker::Lorem.word }
    max_points { 0 }
    course { create(:course) }
  end
end
