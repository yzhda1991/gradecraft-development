FactoryBot.define do
  factory :flagged_user do
    association :course
    association :flagger, factory: :user
    association :flagged, factory: :user
  end
end
