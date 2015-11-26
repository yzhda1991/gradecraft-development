class ChallengeScoreLevel < ActiveRecord::Base
  include ScoreLevel

  belongs_to :challenge
  attr_accessible :challenge_id

  validates_associated :challenge

end
