class Level < ActiveRecord::Base
  include Copyable

  belongs_to :criterion
  has_many :level_badges
  has_many :badges, through: :level_badges
  has_many :criterion_grades

  validates :points, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :name, presence: true, length: { maximum: 30 }

  scope :sorted, -> { order('points ASC') }

  attr_accessible :name, :description, :points, :criterion_id, :durable, :full_credit, :no_credit, :sort_order

  include DisplayHelpers

  def copy(attributes={})
    copy = self.dup
    copy.save unless self.new_record?
    copy.badges << self.badges.map(&:dup)
    copy
  end

end
