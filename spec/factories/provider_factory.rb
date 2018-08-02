FactoryBot.define do
  factory :provider do
    canvas
    consumer_key "secret_key"
    consumer_secret { Faker::Crypto.sha1 }
    consumer_secret_confirmation { consumer_secret }

    factory :institution_provider, class: "Provider" do
      association :providee, factory: :institution
    end

    trait :canvas do
      name "canvas"
    end
  end
end
