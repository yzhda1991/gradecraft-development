FactoryBot.define do
  factory :team_leadership do
    association :team
    association :leader, factory: :user
  end
end
