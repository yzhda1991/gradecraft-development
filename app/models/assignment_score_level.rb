class AssignmentScoreLevel < ActiveRecord::Base
  include ScoreLevel

  belongs_to :assignment

  validates_associated :assignment
end
