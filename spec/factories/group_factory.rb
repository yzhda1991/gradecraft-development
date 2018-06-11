FactoryBot.define do
  factory :group do
    association :course, factory: :course
    text_proposal "how important is it to get this right?"
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
