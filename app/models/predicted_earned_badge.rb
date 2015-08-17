class PredictedEarnedBadge < ActiveRecord::Base

  attr_accessible :student_id, :badge_id, :times_earned

  # `touch: true` is breaking on create and destroy actions
  belongs_to :badge#, touch: true
  belongs_to :student#, touch: true

  def total_predicted_points
    self.badge.total_points * times_earned
  end

end
