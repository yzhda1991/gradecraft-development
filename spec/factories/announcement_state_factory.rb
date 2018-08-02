FactoryBot.define do
  factory :announcement_state do
    association :announcement
    association :user
    read true
  end

end
