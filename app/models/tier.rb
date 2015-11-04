class Tier < ActiveRecord::Base
  belongs_to :metric
  has_many :tier_badges
  has_many :badges, through: :tier_badges
  has_many :rubric_grades

  validates :points, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :name, presence: true, length: { maximum: 30 }

  scope :sorted, -> { order('points ASC') }

  attr_accessible :name, :description, :points, :metric_id, :durable, :full_credit, :no_credit, :sort_order

  include DisplayHelpers

  def copy
    copy = self.dup
    copy.save unless self.new_record?
    copy.badges << self.badges.map(&:dup)
    copy
  end

end
