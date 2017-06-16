# Model concern for behaviors around a grade status for an ActiveRecord class
# that represents a grade with a given status
module GradeStatus
  extend ActiveSupport::Concern

  included do
    scope :graded, -> { where status: "Graded" } # student_visible: true


    scope :in_progress, -> { where status: "In Progress" } # completed: false

    scope :student_visible, ->  { where(student_visible: true) }
  end

  def in_progress?
    status == "In Progress"
  end
end
