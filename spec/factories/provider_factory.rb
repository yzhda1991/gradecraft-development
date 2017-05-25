FactoryGirl.define do
  factory :provider do
    canvas
    consumer_key "secret_key"
    consumer_secret { Faker::Crypto.sha1 }
    consumer_secret_confirmation { consumer_secret }

    association :institution

    trait :canvas do
      name "canvas"
    end
  end
end
