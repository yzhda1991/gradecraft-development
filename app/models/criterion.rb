class Criterion < ActiveRecord::Base
  include Copyable

  belongs_to :rubric
  has_many :levels, dependent: :destroy

  has_many :criterion_grades
  belongs_to :full_credit_level, foreign_key: :full_credit_level_id, class_name: "Level"
  attr_accessible :name, :max_points, :description, :order, :rubric_id, :full_credit_level_id
  attr_accessor :add_default_levels

  after_initialize :set_defaults
  after_create :generate_default_levels, if: :add_default_levels?
  #after_save :update_full_credit, if: :add_default_levels?

  validates :max_points, presence: true
  validates :name, presence: true, length: { maximum: 30 }
  validates :order, presence: true

  scope :ordered, -> { order(:order) }

  def copy(attributes={})
    ModelCopier.new(self).copy(attributes: attributes,
                               associations: [:levels],
                               options: { overrides: [
                                  ->(copy) { copy.add_default_levels = false }]})
  end

  include DisplayHelpers

  protected

  def add_default_levels?
    self.add_default_levels === true
  end

  def set_defaults
    self.add_default_levels = true
  end

  def generate_default_levels
    @full_credit_level = create_full_credit_level
    create_no_credit_level
    #update_attributes full_credit_level_id: @full_credit_level[:id]
  end

  def update_full_credit
    find_and_set_full_credit_level unless full_credit_level
    full_credit_level.update_attributes points: max_points
  end

  def find_and_set_full_credit_level
    full_credit_level = levels.where(full_credit: true).first
    full_credit_level ||= create_full_credit_level
    update_attributes full_credit_level_id: full_credit_level[:id]
  end

  def create_full_credit_level
    levels.create name: "Full Credit", points: max_points, full_credit: true, durable: true, sort_order: 0
  end

  def create_no_credit_level
    levels.create name: "No Credit", points: 0, no_credit: true, durable: true, sort_order: 1000
  end
end
