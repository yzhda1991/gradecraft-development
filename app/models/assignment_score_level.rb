class AssignmentScoreLevel < ActiveRecord::Base
  include ScoreLevel

  belongs_to :assignment
  attr_accessible :assignment_id

  validates_associated :assignment
  
end
