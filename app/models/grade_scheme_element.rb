# Provides the mapping between student's progress and the overall course grade
class GradeSchemeElement < ApplicationRecord
  include Copyable
  include UnlockableCondition

  belongs_to :course

  validates_presence_of :course
  validates :lowest_points, length: { maximum: 9 }, numericality: { only_integer: true }

  scope :for_course, -> (course_id) { where(course_id: course_id) }
  scope :ordered, -> { order({ lowest_points: :desc }, :letter) }
  scope :order_by_points_asc, -> { order lowest_points: :asc }
  scope :order_by_points_desc, -> { order lowest_points: :desc }

  def self.default
    GradeSchemeElement.new(level: "Not yet on board")
  end

  def self.has_valid_elements_for(course)
    course.grade_scheme_elements.all? { |gse| !gse.lowest_points.nil? }
  end

  def self.next_highest_element_for(element)
    ordered_course_elements = GradeSchemeElement.for_course(element.course).order_by_points_asc
    ordered_course_elements[ordered_course_elements.find_index(element) + 1] unless ordered_course_elements.empty?
  end

  def self.next_lowest_element_for(element)
    ordered_course_elements = GradeSchemeElement.for_course(element.course).order_by_points_asc
    current_index = ordered_course_elements.find_index(element)
    return nil if current_index == 0
    ordered_course_elements[current_index - 1]
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
    @next_highest_element ||= GradeSchemeElement.next_highest_element_for self
  end

  def next_lowest_element
    @next_lowest_element ||= GradeSchemeElement.next_lowest_element_for self
  end

  # The highest point value for the element
  def highest_points
    return Float::INFINITY if next_highest_element.nil?
    next_highest_element.lowest_points - 1
  end

  # Calculating the points that covers this element
  # Returns infinity if the element has the highest ordered point value in the course
  def range
    highest_points.to_f - lowest_points.to_f
  end

  def within_range?(score)
    score >= lowest_points && score <= highest_points
  end
end
