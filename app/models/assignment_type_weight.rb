class AssignmentTypeWeight < ApplicationRecord
  belongs_to :student, class_name: "User"
  belongs_to :assignment_type
  belongs_to :course

  before_validation :cache_associations

  validates_presence_of :student, :assignment_type, :course, :weight

  scope :for_course, ->(course) { where(course_id: course.id) }
  scope :for_student, ->(student) { where(student_id: student.id) }

  private

  def cache_associations
    self.course_id ||= assignment_type.try(:course_id)
  end
end
