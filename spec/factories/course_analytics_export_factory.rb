FactoryBot.define do
  factory :course_analytics_export do
    association :course
    association :owner, factory: :user

    s3_object_key "some-object-key"
  end
end
