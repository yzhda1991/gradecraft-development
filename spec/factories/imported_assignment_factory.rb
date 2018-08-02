FactoryBot.define do
  factory :imported_assignment do
    association :assignment
    sequence(:provider_resource_id) {|n| "ASSIGNMENT_#{n}" }
    sequence(:provider_data) { |n| { "course_id" => "COURSE_#{n}" }}

    trait :canvas do
      provider :canvas
    end
  end
end
