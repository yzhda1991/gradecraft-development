class RubricGrade < ActiveRecord::Base
  belongs_to :submission
  belongs_to :metric
  belongs_to :tier
  belongs_to :student, class_name: "User"
  belongs_to :assignment

  scope :for_course, ->(course) do
    joins("LEFT OUTER JOIN assignments ON rubric_grades.assignment_id =\
           assignments.id")
      .joins("LEFT OUTER JOIN submissions ON rubric_grades.submission_id =\
              submissions.id")
      .where("assignments.course_id = :course_id \
              OR submissions.course_id = :course_id", course_id: course.id)
  end
  scope :for_student, ->(student) { where(student_id: student.id) }

  attr_accessible :metric_name, :metric_description, :max_points, :tier_name,
    :tier_description, :points, :submission_id, :metric_id, :tier_id, :order,
    :student_id, :assignment_id, :comments

  validates :max_points, presence: true
  validates :metric_name, presence: true
  # TODO between semesters, validate metric_id
  validates :order, presence: true
  validates :student_id, presence: true
  validate :submission_or_assignment_present

  private

  def submission_or_assignment_present
    submission_id.present? or assignment_id.present?
  end
end
