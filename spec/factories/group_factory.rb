FactoryGirl.define do
  factory :group do
    association :course, factory: :course
    before(:create) do |group|
      (0..3).each { group.students << create(:course_membership, :student, course: group.course).user }
      group.assignments << create(:assignment, grade_scope: "Group", course: group.course)
    end
    name { Faker::Lorem.word }
    approved "Pending"

    factory :approved_group do
      approved "Approved"
    end
  end
end
