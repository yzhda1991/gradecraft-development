FactoryGirl.define do
  factory :course do
    name { Faker::Internet.domain_word }
    courseno { Faker::Internet.domain_word }
    semester 'Fall'
    badge_setting false

    factory :course_accepting_groups do
      min_group_size 2
      max_group_size 10
    end

    total_assignment_weight ""
    max_assignment_weight ""
    max_assignment_types_weighted ""
    default_assignment_weight ""
    point_total ""
  end
end
