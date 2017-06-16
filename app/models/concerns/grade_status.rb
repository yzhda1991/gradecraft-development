# Model concern for behaviors around a grade status for an ActiveRecord class
# that represents a grade with a given status
module GradeStatus
  extend ActiveSupport::Concern

  included do
    scope :graded, -> { where status: "Graded" } # student_visible: true
    scope :in_progress, -> { where status: "In Progress" } # completed: false
    scope :not_released, -> { where status: "In Progress" } # completed: true, student_visible: false
    scope :released, -> { where status: "Released" } # student_visible: true

    scope :student_visible, ->  { where(student_visible: true) }
  end

  STATUSES = ["In Progress", "Released"]

  def is_graded?
    status == "Graded"
  end

  def in_progress?
    status == "In Progress"
  end

  def is_released?
    status == "Released"
  end

  # temporary method to manage new boolean fields: complete, and student_visibile
  # this will be removed once these fields are used for grade status logic
  def update_status_fields
    if self.status == "In Progress"
      self.complete = false
      self.student_visible = false
    elsif self.status == "Graded"
      if assignment.release_necessary
        self.complete = true
        self.student_visible = false
      else
        self.complete = true
        self.student_visible = true
      end
    elsif self.status == "Released"
      self.complete = true
      self.student_visible = true
    end
    return true
  end

  # temporary method for challenge grades, same as above
  def update_challenge_status_fields
    if self.status == "In Progress"
      self.instructor_modified = true
      self.complete = false
      self.student_visible = false
    elsif self.status == "Graded"
      self.instructor_modified = true
      if challenge.release_necessary
        self.complete = true
        self.student_visible = false
      else
        self.complete = true
        self.student_visible = true
      end
    elsif self.status == "Released"
      self.instructor_modified = true
      self.complete = true
      self.student_visible = true
    end
    return true
  end
end
