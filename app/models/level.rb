class Level < ActiveRecord::Base
  include Copyable

  belongs_to :criterion
  has_many :level_badges
  has_many :badges, through: :level_badges
  has_many :criterion_grades

  validates :points, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :name, presence: true, length: { maximum: 30 }

  before_save :update_criterion_meets_expectations_points

  scope :ordered, -> { order("points ASC") }

  attr_accessible :name, :description, :points, :criterion_id,
    :full_credit, :no_credit, :meets_expectations, :sort_order

  include DisplayHelpers

  def above_expectations?
    # We treat criterion without a 'meets expectations' level as if none
    # of it's levels are above expectations
    return false if criterion.meets_expectations_level_id.nil?
    points > criterion.meets_expectations_points
  end

  def copy(attributes={})
    ModelCopier.new(self).copy(attributes: attributes, associations: [:badges])
  end

  private

  def update_criterion_meets_expectations_points
    if points_changed? && meets_expectations?
      criterion.update(meets_expectations_points: points)
    end
  end
end
