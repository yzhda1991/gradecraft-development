FactoryBot.define do
  factory :assignment do
    name { Faker::Lorem.word }
    association :course
    assignment_type { association :assignment_type, course: course }
    description { Faker::Lorem.sentence }
    full_points { Faker::Number.number(5) }
    required false
    student_logged false
    resubmissions_allowed false
    hide_analytics false
    grade_scope "Individual"
    accepts_submissions true
    visible true
    use_rubric true
    accepts_attachments true
    accepts_text true
    accepts_links true
    pass_fail false
    visible_when_locked true
    show_name_when_locked true
    show_points_when_locked true
    threshold_points 0
    show_description_when_locked true
    show_purpose_when_locked true

    factory :individual_assignment do
      grade_scope "Individual"
    end

    factory :group_assignment do
      grade_scope "Group"
    end

    factory :individual_assignment_with_submissions do
      grade_scope "Individual"
      accepts_submissions true
    end

    factory :assignment_with_due_at do
      due_at Date.today
    end

    trait :pass_fail do
      pass_fail true
    end

    trait :closed do
      open_at Faker::Date.forward(3)
    end
  end
end
