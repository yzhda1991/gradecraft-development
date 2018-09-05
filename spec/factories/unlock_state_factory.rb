FactoryBot.define do
  factory :unlock_state do
    association :unlockable, factory: :badge
    association :student, factory: :user
    unlockable_type { "Badge" }
    unlocked { false }
  end
end
