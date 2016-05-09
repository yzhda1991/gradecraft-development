module PredictorData
  extend ActiveSupport::Concern

  private

  def predictor_badges(student)
    current_course.badges.select(
      :id,
      :name,
      :description,
      :point_total,
      :visible,
      :visible_when_locked,
      :can_earn_multiple_times,
      :position,
      :updated_at,
      :icon
    ).map do |badge|
      prediction = badge.find_or_create_predicted_earned_badge(student.id)
      if current_user.is_student?(current_course)
        badge.prediction = {
          id: prediction.id,
          times_earned: prediction.times_earned_including_actual
        }
        badge
      else
        badge.prediction = {
          id: prediction.id,
          times_earned: prediction.actual_times_earned
        }
        badge
      end
    end
  end
end
