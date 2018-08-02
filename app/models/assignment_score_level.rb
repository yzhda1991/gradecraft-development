class AssignmentScoreLevel < ApplicationRecord
  include ScoreLevel

  belongs_to :assignment

  validates_associated :assignment
  validates_numericality_of :points, length: { maximum: 9 }
end
