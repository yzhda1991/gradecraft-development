FactoryGirl.define do
  factory :course_membership do
    association :course
    association :user

    factory :student_course_membership do
      role 'student'
    end

    factory :staff_course_membership do
      role 'gsi'
    end

    factory :professor_course_membership do
      role 'professor'
    end

    factory :admin_course_membership do
      role 'admin'
    end

  end
end
