class AssignmentType < ActiveRecord::Base
  include Copyable

  acts_as_list scope: :course

  attr_accessible :max_points, :name, :description, :student_weightable,
    :position

  belongs_to :course, touch: true
  has_many :assignments, -> { order("position ASC") }, dependent: :destroy
  has_many :submissions, through: :assignments
  has_many :grades

  # This is the assignment weighting system (students decide how much
  # assignments will be worth for them)
  has_many :weights, class_name: "AssignmentTypeWeight", dependent: :destroy

  validates_presence_of :name
  validate :positive_max_points

  scope :student_weightable, -> { where(student_weightable: true) }

  default_scope { order "position" }

  def copy(attributes={})
    ModelCopier.new(self).copy(attributes: attributes, associations: [:assignments])
  end

  # weights default to 1 if not weightable, and
  # 0 if weightable but not weighted by the student
  def weight_for_student(student)
    return 1 unless student_weightable?
    weights.where(student: student).first.try(:weight) || course.default_weight
  end

  def is_capped?
    max_points.present?
  end

  # Getting the assignment types max value if it's present, else returning the
  # summed total of assignment points
  def total_points
    if max_points.present?
      max_points
    else
      summed_assignment_points
    end
  end

  # Calculating the total number of assignment points in the type
  def summed_assignment_points
    assignments.map{ |a| a.point_total || 0 }.sum
  end

  def total_points_for_student(student)
    if max_points.present?
      max_points
    else
      if student_weightable?
        weighted_total_for_student(student)
      else
        summed_assignment_points
      end
    end
  end

  def weighted_total_for_student(student)
    if weight_for_student(student) >= 1
      (total_points * weight_for_student(student)).to_i
    else
      (total_points * course.default_weight).to_i
    end
  end

  def visible_score_for_student(student)
    score = score_for_student(student)
    if max_points? && score > max_points
      return max_points
    else
      return score
    end
  end

  def score_for_student(student)
    student.grades.student_visible
                  .not_nil
                  .included_in_course_score
                  .where(assignment_type: self).pluck("score").sum || 0
  end

  def raw_score_for_student(student)
    student.grades.student_visible.where(assignment_type: self).pluck("raw_score").compact.sum || 0
  end

  private

  def positive_max_points
    if max_points? && max_points < 1
      errors.add :base, "Maximum points must be a positive number."
    end
  end
end
