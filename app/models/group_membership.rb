class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :course
  belongs_to :student, class_name: "User"

  scope :for_course, ->(course) do
    joins(:group).where(groups: { course_id: course.id })
  end
  scope :for_student, ->(student) { where(student_id: student.id) }

  validates_uniqueness_of :student_id, { scope: :group_id }
end
