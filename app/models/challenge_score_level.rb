class ChallengeScoreLevel < ActiveRecord::Base
  include ScoreLevel

  belongs_to :challenge

  validates_associated :challenge
end
