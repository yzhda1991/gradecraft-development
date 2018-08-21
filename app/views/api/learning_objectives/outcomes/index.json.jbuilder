json.data @cumulative_outcomes do |cumulative_outcome|
  json.type "learning_objective_cumulative_outcome"
  json.id cumulative_outcome.id.to_s

  json.attributes do
    json.merge! cumulative_outcome.attributes
    json.user_full_name cumulative_outcome.user.name
    json.status cumulative_outcome.learning_objective.progress cumulative_outcome.user
    json.numeric_progress cumulative_outcome.learning_objective.numeric_progress cumulative_outcome.user
    json.percent_complete cumulative_outcome.learning_objective.percent_complete cumulative_outcome.user
  end

  json.relationships do
    json.observed_outcomes do
      json.data @observed_outcomes do |observed_outcome|
        json.type "learning_objective_observed_outcome"
        json.id observed_outcome.id.to_s
      end
    end
  end
end

json.included do
  json.array! @observed_outcomes do |observed_outcome|
    next unless GradeProctor.new(observed_outcome.grade).viewable?(user: current_user)

    json.type "learning_objective_observed_outcome"
    json.id observed_outcome.id.to_s

    json.attributes do
      json.merge! observed_outcome.attributes
      json.learning_objective_assessable_id observed_outcome.learning_objective_assessable_id.to_s

      if observed_outcome.learning_objective_level.present?
        json.flagged_value observed_outcome.learning_objective_level.flagged_value
        json.readable_flagged_value observed_outcome.learning_objective_level.readable_flagged_value
      end

      unless observed_outcome.grade.nil?
        json.grade_id observed_outcome.grade.id

        observed_outcome.grade.assignment.tap do |assignment|
          json.assignment_id assignment.id
          json.assignment_name assignment.name
        end
      end
    end
  end
end

json.meta do
  json.term_for_students term_for :students
  json.term_for_groups term_for :groups
end
