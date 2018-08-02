FactoryBot.define do
  factory :team do
    association :course
    name { Faker::Team.name }
  end
end
