FactoryBot.define do
  factory :unlock_condition do
    association :course
    association :unlockable, factory: :badge
    association :condition, factory: :assignment
    unlockable_type { "Badge" }
    condition_type { "Assignment" }
    condition_state { "Earned" }

    factory :unlock_condition_for_assignment do
      association :course
      association :unlockable, factory: :assignment
      unlockable_type { "Assignment" }
    end

    factory :unlock_condition_for_gse do
      association :course
      association :unlockable, factory: :grade_scheme_element
      unlockable_type { "GradeSchemeElement" }
    end
  end
end
