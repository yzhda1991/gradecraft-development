class PredictedEarnedChallenge < ActiveRecord::Base

  attr_accessible :student_id, :challenge_id, :points_earned

  belongs_to :challenge
  belongs_to :student

end
