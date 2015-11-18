FactoryGirl.define do
  factory :predicted_earned_badge do
    association :badge
    association :student, factory: :user
    times_earned { rand(3) }
  end
end
