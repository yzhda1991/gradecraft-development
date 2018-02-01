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
    end
  end

  json.array! @objective.assignments do |assignment|
    json.partial! 'api/assignments/assignment', assignment: assignment
  end

  json.array! @objective.cumulative_outcomes do |cumulative_outcome|
    json.type "learning_objective_cumulative_outcome"
    json.id cumulative_outcome.id.to_s

    json.attributes do
      json.merge! cumulative_outcome.attributes
      json.user_full_name cumulative_outcome.user.name
      json.status cumulative_outcome.learning_objective.progress current_user
    end
  end if @include_outcomes
end

json.meta do
  json.level_flagged_values LearningObjectiveLevel.flagged_values
end
