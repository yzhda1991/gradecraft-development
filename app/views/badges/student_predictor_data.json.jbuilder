json.badges @badges do |badge|
  next unless badge.visible
  next unless badge.point_total && badge.point_total > 0
  json.merge! badge.attributes
  json.icon badge.icon.url
  json.predicted_score 0
  json.info ! badge.description.blank?
  json.total_earned_points badge.earned_badge_total_points(current_student)
  json.earned_badge_count badge.earned_badge_count_for_student(current_student)

  badge.student_predicted_earned_badge.tap do |prediction|
    json.prediction do
      json.id prediction.id

      # We persist the student's last prediction, but the predictor will start the student's
      # predicted earning count at no less that the number of badges she already earned.
      if prediction.times_earned < badge.earned_badge_count_for_student(current_student)
        json.times_earned badge.earned_badge_count_for_student(current_student)
      else
        json.times_earned prediction.times_earned
      end
    end
  end
end

json.term_for_badges term_for :badges
