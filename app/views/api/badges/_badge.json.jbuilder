json.type "badges"
json.id   badge.id.to_s

json.attributes do
  json.merge! badge.attributes
  json.icon badge.icon.url
  json.default_url !badge.icon.file.present?

  json.is_a_condition badge.is_a_condition?
  if badge.is_a_condition?
    json.unlock_keys badge.unlock_keys.map {
      |key| "#{key.unlockable.name} is unlocked by #{key.condition_state} #{key.condition.name}"
      }
  end

  json.has_info !badge.description.blank?

  if @student.present?
    json.total_earned_points badge.earned_badge_total_points_for_student(@student)
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
  if badge.badge_files.present?
    json.file_uploads do
      json.data badge.badge_files do |badge_file|
        json.type "file_uploads"
        json.id badge_file.id.to_s
      end
    end
  end

  if @predicted_earned_badges.present? &&  @predicted_earned_badges.where(badge_id: badge.id).present?
    json.prediction data: {
      type: "predicted_earned_badges",
      id: @predicted_earned_badges.where(badge_id: badge.id).first.id.to_s
    }
  end

  if @earned_badges.present? && @earned_badges.where(badge_id: badge.id).present?
    json.earned_badge data: {
      type: "earned_badges",
      id: @earned_badges.where(badge_id: badge.id).first.id.to_s
    }
  end
end
