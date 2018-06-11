FactoryBot.define do
  factory :submissions_export do
    association :course
    association :professor, factory: :user
    association :team
    association :assignment
  end
end
