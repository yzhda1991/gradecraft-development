FactoryGirl.define do
  factory :challenge_grade do
    association :challenge
    association :team
  end
end
