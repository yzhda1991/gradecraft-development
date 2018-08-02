FactoryBot.define do
  factory :criterion_grade do
    association :student, factory: :user
    association :assignment
    association :criterion
    association :level

    factory :criterion_grade_with_level do
      after(:build) do |cg|
        cg.level = create(:level, criterion: cg.criterion)
      end
    end
  end
end
