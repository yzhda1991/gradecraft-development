FactoryGirl.define do
  factory :user_authorization do
    access_token { Faker::Crypto.sha1 }
    association :user

    trait :canvas do
      provider "canvas"
    end
  end
end
