class PredictedEarnedChallenge < ApplicationRecord
  belongs_to :challenge
  belongs_to :student, class_name: "User"

  scope :for_course, ->(course) do
    joins(:challenge).where(challenges: {course_id: course.id})
  end
  scope :for_student, ->(student) { where(student_id: student.id) }

  validates :student, presence: true
  validates :challenge, presence: true, uniqueness: { scope: :student_id }
end
