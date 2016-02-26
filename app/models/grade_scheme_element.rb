# Provides the mapping between student's progress and the overall course grade
class GradeSchemeElement < ActiveRecord::Base
  include Copyable
  attr_accessible :letter, :low_range, :high_range, :level, :description,
                  :course_id, :course, :updated_at

  belongs_to :course, touch: true

  validates_presence_of :low_range, :high_range, :course
  validates_numericality_of :high_range,
                            greater_than: proc { |e| e.low_range.to_i }

  scope :for_course, -> (course_id) { where(course_id: course_id) }
  scope :order_by_low_range, -> { order "low_range ASC" }
  scope :order_by_high_range, -> { order "high_range DESC" }

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

  # Calculating the range that covers this element
  def range
    high_range.to_f - low_range.to_f
  end

  # Figuring out how many points a student has to earn the next level
  def points_to_next_level(student, course)
    # if high range, +1
    high_range - student.cached_score_for_course(course) + 1
  end

  # Calculating how far a student is through this level
  def progress_percent(student)
    ((student.cached_score_for_course(course) - low_range) / range) * 100
  end

  def within_range?(score)
    score >= low_range && score <= high_range
  end
end
