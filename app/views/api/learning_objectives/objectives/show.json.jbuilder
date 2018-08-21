json.data do
  json.type "learning_objective"
  json.id @objective.id

  json.attributes do
    json.partial! 'api/learning_objectives/objectives/objective', objective: @objective
  end
end

json.included do
  json.array! @objective.levels do |level|
    json.type "levels"
    json.id level.id.to_s

    json.attributes do
      json.merge! level.attributes
      json.readable_flagged_value level.readable_flagged_value
    end
  end

  json.array! @objective.assignments do |assignment|
    json.type "assignments"
    json.id assignment.id.to_s

    json.attributes do
      json.id assignment.id
      json.name assignment.name
      json.assignment_id assignment.id
      json.objective_id @objective.id

      json.has_groups assignment.has_groups?
      json.is_a_condition assignment.is_a_condition?

      if current_user_is_student?
        json.is_locked !assignment.is_unlocked_for_student?(current_user)
        json.has_been_unlocked assignment.is_unlockable? && assignment.is_unlocked_for_student?(current_user)
      end

      json.partial! 'api/assignments/assignment_unlocks', assignment: assignment
    end
  end

  json.array! @objective.cumulative_outcomes do |cumulative_outcome|
    json.type "learning_objective_cumulative_outcome"
    json.id cumulative_outcome.id.to_s

    json.attributes do
      json.merge! cumulative_outcome.attributes
      json.full_name cumulative_outcome.user.name
      json.status cumulative_outcome.learning_objective.progress current_user
    end
  end if @include_outcomes
end

json.meta do
  json.term_for_assignment term_for :assignment
  json.term_for_assignments term_for :assignments
  json.term_for_learning_objective term_for :learning_objective
  json.level_flagged_values LearningObjectiveLevel.flagged_values_to_h
end
