class Rubric < ActiveRecord::Base
  include Copyable

  belongs_to :assignment
  belongs_to :course
  has_many :criteria

  validates :assignment, presence: true

  def max_level_count
    criteria.inject([]) do |level_counts, criterion|
      level_counts << criterion.levels.count
    end.max
  end

  def designed?
    criteria.count > 0
  end

  def copy(attributes={})
    ModelCopier.new(self).copy(attributes: attributes, associations: [:criteria])
  end
end
