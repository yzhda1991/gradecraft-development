json.data @badges do |badge|
  next unless BadgeProctor.new(badge).viewable?(current_user)
  json.type "badges"
  json.id   badge.id.to_s

  json.attributes do
    json.merge! badge.attributes
    json.icon badge.icon.url

    json.is_a_condition badge.is_a_condition?
    if badge.is_a_condition?
      json.unlock_keys badge.unlock_keys.map {
        |key| "#{key.unlockable.name} is unlocked by #{key.condition_state} #{key.condition.name}"
        }
    end

    json.has_info !badge.description.blank?

    if @student.present?
      json.total_earned_points badge.earned_badge_total_points(@student)
      json.earned_badge_count badge.earned_badge_count_for_student(@student)
      json.available_for_student badge.available_for_student?(@student)

      json.is_locked !badge.is_unlocked_for_student?(@student)

      json.has_been_unlocked badge.is_unlockable? && badge.is_unlocked_for_student?(@student)
      if badge.is_unlockable?
        json.unlock_conditions badge.unlock_conditions.map {
          |condition| "#{condition.name} must be #{condition.condition_state}"
        }
      end
    end
  end

  json.relationships do
    if @predicted_earned_badges.present?
      json.prediction data: {
        type: "predicted_earned_badges",
        id: @predicted_earned_badges.where(badge_id: badge.id).first.id
      }
    end

    if @earned_badges.present? && @earned_badges.where(badge_id: badge.id).present?
      json.earned_badge data: {
        type: "earned_badges",
        id: @earned_badges.where(badge_id: badge.id).first.id
      }
    end
  end
end

json.included do
  if @predicted_earned_badges.present?
    json.array! @predicted_earned_badges do |predicted_earned_badge|
      json.type "predicted_earned_badges"
      json.id predicted_earned_badge.id
      json.attributes do
        json.id predicted_earned_badge.id
        json.student_id predicted_earned_badge.student_id
        json.predicted_times_earned \
          predicted_earned_badge.times_earned_including_actual
      end
    end
  end

  if @earned_badges.present?
    json.array! @earned_badges do |earned_badge|
      json.type "earned_badges"
      json.id earned_badge.id
      json.attributes do
        json.merge! earned_badge.attributes
      end
    end
  end
end

json.meta do
  json.term_for_badges term_for :badges
  json.term_for_badge term_for :badge
  json.update_predictions @update_predictions
end
