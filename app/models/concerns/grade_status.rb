# Model concern for behaviors around a grade status for an ActiveRecord class
# that represents a grade with a given status
module GradeStatus
  extend ActiveSupport::Concern

  included do
    scope :graded, -> { where status: "Graded" }
    scope :graded_or_released, -> { where(status: ["Graded", "Released"]) }
    scope :in_progress, -> { where status: "In Progress" }
    scope :not_released, -> { joins(releasable_relationship)
                              .where("#{releasable_relationship.to_s.tableize}" => { release_necessary: true })
                              .where(status: "Graded")
                            }
    scope :released, -> { joins(releasable_relationship)
                          .where("status = 'Released' OR "\
                                "(status = 'Graded' AND NOT #{releasable_relationship.to_s.tableize}.release_necessary)")
                              }
    scope :student_visible, -> { joins(releasable_relationship).where(student_visible_sql) }
  end

  class_methods do
    # Used in class definitions to specify which belongs_to relationship responds to a release_necessary flag
    # This is used in the scopes to determine what relationship to join with
    # USAGE:
    # class Grade
    #   releasable_through :assignment
    # end
    def releasable_through(relationship=nil)
      @releasable_relationship = relationship
    end

    # returns the relationship symbol set in the class definition
    def releasable_relationship
      @releasable_relationship
    end

    private

    def student_visible_sql
      ["status = 'Released' OR (status = 'Graded' AND #{releasable_relationship.to_s.tableize}.release_necessary = ?)", false]
    end
  end

  STATUSES = ["In Progress", "Graded", "Released"]
  UNRELEASED_STATUSES = ["In Progress", "Graded"]

  def is_graded?
    status == "Graded"
  end

  def in_progress?
    status == "In Progress"
  end

  def is_released?
    status == "Released"
  end

  def graded_or_released?
    is_graded? || is_released?
  end

  def is_student_visible?
    if is_released? || (is_graded? && !assignment.release_necessary?)
      return true
    else
      return false
    end
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
end
