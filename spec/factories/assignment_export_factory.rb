FactoryGirl.define do
  factory :assignment_export do
    factory :assignment_export_with_associations do
      association :course
      association :professor, factory: :user
      association :team
      association :assignment
    end
  end
end
