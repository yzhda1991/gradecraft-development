class Rubric < ActiveRecord::Base
  include Copyable

  belongs_to :assignment
  has_many :criteria

  validates :assignment, presence: true

  attr_accessible :assignment_id

  def max_level_count
    criteria.inject([]) do |level_counts, criterion|
      level_counts << criterion.levels.count
    end.max
  end

  def designed?
    criteria.count > 0
  end

  def copy(attributes={})
    copy = self.dup
    copy.save unless self.new_record?
    copy.criteria << self.criteria.map(&:copy)
    copy
  end
end
