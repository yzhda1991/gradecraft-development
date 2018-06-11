FactoryBot.define do
  factory :announcement do
    title { Faker::Lorem.words(5).join(" ") }
    body { Faker::Lorem.paragraph(2) }
    association :course
    association :author, factory: :user

    trait :for_recipient do
      association :recipient, factory: :user
    end
  end
end
