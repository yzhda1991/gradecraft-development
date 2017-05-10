FactoryGirl.define do
  factory :institution do
    name { Faker::University.unique.name }
  end
end
