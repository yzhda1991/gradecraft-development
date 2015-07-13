FactoryGirl.define do
  factory :event do
    name { Faker::Lorem.word }
    due_at {Faker::Date.forward(23)}
  end
end
