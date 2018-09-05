FactoryBot.define do
  factory :challenge_grade do
    association :challenge
    association :team

    factory :in_progress_challenge_grade do
      association :team
      raw_points { rand(challenge.full_points) }
      instructor_modified { true }
      complete { false }
    end

    factory :student_visible_challenge_grade do
      raw_points { Faker::Number.number(5) }
      instructor_modified { true }
      complete { true }
      student_visible { true }
    end
  end
end
