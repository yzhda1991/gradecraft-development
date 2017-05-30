FactoryGirl.define do
  factory :institution do
    name { Faker::University.unique.name }
    has_site_license true

    trait :without_site_license do
      has_site_license false
    end
  end
end
