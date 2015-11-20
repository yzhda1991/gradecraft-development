class AssignmentScoreLevel < ActiveRecord::Base
  include ScoreLevel

  belongs_to :assignment
  attr_accessible :assignment_id

  validates_associated :assignment

  #Displaying the name and the point value together in grading lists
  def formatted_name
    "#{name} (#{value} points)"
  end

  def copy
    self.dup
  end
end
