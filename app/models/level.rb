class Level < ActiveRecord::Base
  include Copyable

  belongs_to :criterion
  has_many :level_badges
  has_many :badges, through: :level_badges
  has_many :criterion_grades

  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :name, presence: true, length: { maximum: 30 }

  scope :ordered, -> { order("points ASC") }
  scope :sorted, -> { order("sort_order ASC")}

  def above_expectations?
    # We treat criterion without a 'meets expectations' level as if none
    # of it's levels are above expectations
    return false if criterion.meets_expectations_level_id.nil?
    points > criterion.meets_expectations_points
  end

  def copy(attributes={}, lookup_store=nil)
    ModelCopier.new(self, lookup_store).copy(attributes: attributes,
      associations: [{ level_badges: { level_id: :id }}])
  end

  # Determines if the specified student has earned this level.
  # Returns `true` if a `CriterionGrade` exists for this student;
  # otherwise `false`.
  def earned_for?(student_id)
    self.criterion_grades.where(student_id: student_id).exists?
  end

  def hide_analytics?
    assignment = self.criterion.rubric.assignment
    assignment.hide_analytics? || !assignment.course.show_analytics?
  end

  def points=(points)
    write_attribute(:points, points)
    if points_changed? && meets_expectations?
      criterion.update(meets_expectations_points: points)
    end
  end
end
