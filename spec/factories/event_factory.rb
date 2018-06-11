FactoryBot.define do
  factory :event do
    association :course
    name { Faker::Lorem.word }
    due_at {Faker::Date.forward(23)}
  end
end
