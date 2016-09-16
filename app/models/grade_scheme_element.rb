# Provides the mapping between student's progress and the overall course grade
class GradeSchemeElement < ActiveRecord::Base
  include Copyable
  include UnlockableCondition

  belongs_to :course, touch: true

  validates_presence_of :lowest_points, :highest_points, :course
  validates_numericality_of :highest_points,
                            greater_than: proc { |e| e.lowest_points.to_i }

  scope :for_course, -> (course_id) { where(course_id: course_id) }
  scope :order_by_lowest_points, -> { order "lowest_points ASC" }
  scope :order_by_highest_points, -> { order "lowest_points DESC" }

  def self.default
    GradeSchemeElement.new(level: "Not yet on board")
  end

  # Getting the name of the Grade Scheme Element - the Level if it's present,
  # the Letter if not
  def name
    if level? && letter?
      "#{letter} / #{level}"
    elsif level?
      level
    elsif letter?
      letter
    else
      return nil
    end
  end

  # Calculating the points that covers this element
  def range
    highest_points.to_f - lowest_points.to_f
  end

  # Figuring out how many points a student has to earn the next level
  def points_to_next_level(student, course)
    # if high points, +1
    highest_points - student.cached_score_for_course(course) + 1
  end

  # Calculating how far a student is through this level
  def progress_percent(student)
    ((student.cached_score_for_course(course) - lowest_points) / range) * 100
  end

  def within_range?(score)
    score >= lowest_points && score <= highest_points
  end

  def count_students_earned
    course.course_memberships.being_graded.where(earned_grade_scheme_element_id: self.id).count
  end
end
