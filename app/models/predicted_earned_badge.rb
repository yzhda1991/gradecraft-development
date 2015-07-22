class PredictedEarnedBadge < ActiveRecord::Base

  attr_accessible :student_id, :badge_id, :times_earned

  belongs_to :badge
  belongs_to :student

  def total_predicted_points
    self.badge.total_points * times_earned
  end

end
