FactoryBot.define do
  factory :institution do
    name { Faker::University.unique.name }
    has_site_license { true }

    trait :without_site_license do
      has_site_license { false }
    end

    trait :k_12 do
      institution_type { "K-12" }
    end

    trait :higher_ed do
      institution_type { "Higher Education" }
    end

    trait :other do
      institution_type { "Other" }
    end
  end
end
