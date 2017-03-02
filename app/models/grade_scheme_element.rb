# Provides the mapping between student's progress and the overall course grade
class GradeSchemeElement < ActiveRecord::Base
  include Copyable
  include UnlockableCondition

  belongs_to :course, touch: true

  validates_presence_of :lowest_points, :course

  scope :for_course, -> (course_id) { where(course_id: course_id) }
  scope :order_by_lowest_points, -> { order "lowest_points ASC" }
  scope :order_by_highest_points, -> { order "lowest_points DESC" }

  def self.default
    GradeSchemeElement.new(level: "Not yet on board")
  end

  def self.next_highest_element(element)
    nextElement = nil
    ordered_course_elements = GradeSchemeElement.for_course(element.course).order_by_lowest_points
    ordered_course_elements.each_with_index do |currentElement, i|
      if element == currentElement
        nextElement = ordered_course_elements[i+1]
        break
      end
    end
    nextElement
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

  # Figuring out how many points a student has to earn the next level
  def points_to_next_level(student, course)
    return 0 if next_highest_element.nil?
    next_highest_element.lowest_points - student.score_for_course(course)
  end

  # Calculating how far a student is through this level
  def progress_percent(student)
    return 100 if range == Float::INFINITY
    ((student.score_for_course(course).to_f - lowest_points.to_f) / range) * 100
  end

  def count_students_earned
    course.course_memberships.being_graded.where(earned_grade_scheme_element_id: self.id).count
  end

  def next_highest_element
    GradeSchemeElement.next_highest_element self
  end

  # Calculating the points that covers this element
  # Returns infinity if the element has the highest ordered point value in the course
  def range
    return Float::INFINITY if next_highest_element.nil?
    (next_highest_element.lowest_points - 1).to_f - lowest_points.to_f
  end

  def within_range?(score)
    score >= lowest_points && score <= highest_points
  end
end
