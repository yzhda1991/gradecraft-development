module GradeStatus
  extend ActiveSupport::Concern

  included do
    attr_accessible :status

    scope :graded, -> { where status: "Graded" }
    scope :graded_or_released, -> { where(status: ["Graded", "Released"])}
    scope :in_progress, -> { where status: "In Progress" }
  end

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
end
