FactoryGirl.define do
  factory :assignment_type do
    name { Faker::Lorem.word }
    course { create(:course) }
  end
end
