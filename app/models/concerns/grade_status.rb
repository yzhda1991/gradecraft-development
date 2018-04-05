# Model concern for behaviors around a grade status for an ActiveRecord class
# that represents a grade with a given status
module GradeStatus
  extend ActiveSupport::Concern

  included do
    scope :in_progress, -> { where(instructor_modified: true, complete: false) }
    scope :not_released, -> { where(instructor_modified: true, student_visible: false)}
    scope :ready_for_release, -> { where(instructor_modified: true, complete: true, student_visible: false)}
    scope :student_visible, ->  { where(student_visible: true) }
    scope :complete, -> { where(student_visible: true, complete: true) }
  end

  def in_progress?
    instructor_modified == true && complete == false
  end

  def not_released?
    instructor_modified == true && student_visible == false
  end
end
