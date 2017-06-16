# Model concern for behaviors around a grade status for an ActiveRecord class
# that represents a grade with a given status
module GradeStatus
  extend ActiveSupport::Concern

  included do
    scope :in_progress, -> { where(instructor_modified: true, complete: false) }
    scope :complete, ->  { where(complete: true) }
    scope :student_visible, ->  { where(student_visible: true) }
  end

  def in_progress?
    instructor_modified == true && complete == false
  end
end
