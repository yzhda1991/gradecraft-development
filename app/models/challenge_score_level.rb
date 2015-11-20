class ChallengeScoreLevel < ActiveRecord::Base
  include ScoreLevel

  belongs_to :challenge
  attr_accessible :challenge_id

  def formatted_name
    "#{name} - #{value} points"
  end
end
