FactoryGirl.define do
  factory :assignment_type do
    name { Faker::Lorem.word }
    course { create(:course) }
    points_predictor_display 'Fixed'
  end
end
