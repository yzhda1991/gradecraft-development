class ChallengeScoreLevel < ApplicationRecord
  include ScoreLevel

  belongs_to :challenge

  validates_associated :challenge
  validates_numericality_of :points, length: { maximum: 9 }
end
