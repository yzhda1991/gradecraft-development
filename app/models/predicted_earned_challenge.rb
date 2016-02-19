class PredictedEarnedChallenge < ActiveRecord::Base

  attr_accessible :student_id, :challenge_id, :points_earned

  belongs_to :challenge
  belongs_to :student, :class_name => "User"

  scope :for_course, ->(course) do
    joins(:challenge).where(challenges: {course_id: course.id})
  end
  scope :for_student, ->(student) { where(student_id: student.id) }

end
