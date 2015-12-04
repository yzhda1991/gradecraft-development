FactoryGirl.define do
  factory :student_academic_history
    association :user
    major { Faker::Book.genre }
    gpa { Faker::Number.decimal(2)}

  end
end
:gpa, :current_term_credits, :accumulated_credits, :year_in_school,
  :state_of_residence, :high_school, :athlete, :act_score, :sat_score