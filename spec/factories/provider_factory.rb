FactoryGirl.define do
  factory :provider do
    canvas
    consumer_key "secret_key"
    consumer_secret { Faker::Crypto.sha1 }

    trait :canvas do
      name "canvas"
    end
  end
end
