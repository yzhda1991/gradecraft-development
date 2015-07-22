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
      json.times_earned prediction.times_earned
    end
  end
end

json.term_for_badges term_for :badges
