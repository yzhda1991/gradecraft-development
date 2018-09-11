if assignment.unlock_conditions.present?
  unlock_conditions = assignment.unlock_conditions.map do |condition|
    condition.requirements_description_sentence(current_user.time_zone)
  end
  json.unlock_conditions unlock_conditions

  unlocked_conditions = assignment.unlock_conditions.map do |condition|
    condition.requirements_completed_sentence(current_user.time_zone)
  end
  json.unlocked_conditions unlocked_conditions

  # used in predictor front end to determine if any conditions are closed
  json.conditional_assignment_ids assignment.unlock_conditions.where(condition_type: "Assignment").pluck(:condition_id)
end

if assignment.unlock_keys.present?
  unlock_keys = assignment.unlock_keys.map do |key|
    key.key_description_sentence(current_user.time_zone)
  end
  json.unlock_keys unlock_keys
end
