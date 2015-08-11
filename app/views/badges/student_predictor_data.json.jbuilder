json.badges @badges do |badge|
  cache ["v1", badge] do
    next unless badge.visible
    next unless badge.point_total && badge.point_total > 0
    json.merge! badge.attributes
    json.icon badge.icon.url
    json.info ! badge.description.blank?
    json.total_earned_points badge.earned_badge_total_points(@student)
    json.earned_badge_count badge.earned_badge_count_for_student(@student)

    badge.student_predicted_earned_badge.tap do |prediction|
      cache ["v1", prediction] do
        json.prediction do
          json.id prediction.id

          if current_user.is_staff?(current_course)
            json.times_earned badge.earned_badge_count_for_student(@student)
          else
            # We persist the student's last prediction, but the predictor will start the student's
            # predicted earning count at no less that the number of badges she already earned.
            if prediction.times_earned < badge.earned_badge_count_for_student(@student)
             json.times_earned badge.earned_badge_count_for_student(@student)
            else
             json.times_earned prediction.times_earned
            end
          end
        end
      end
    end
  end
end

json.term_for_badges term_for :badges
