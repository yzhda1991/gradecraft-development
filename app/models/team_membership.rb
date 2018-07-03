class TeamMembership < ApplicationRecord
  include Copyable

  belongs_to :team
  belongs_to :student, class_name: "User"

  validates_associated :team, :student

  scope :for_course, ->(course) do
    joins(:team).where(teams: {course_id: course.id})
  end

  scope :for_student, ->(student) { where(student_id: student.id) }

end
