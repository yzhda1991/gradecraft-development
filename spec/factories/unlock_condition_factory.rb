FactoryGirl.define do
  factory :unlock_condition do
    association :unlockable, factory: :assignment
    association :condition, factory: :assignment
 		condition_state 'Earned'
  end
end