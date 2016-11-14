json.data do
  return if @assignment.course != current_course

  json.type "assignments"
  json.id @assignment.id.to_s
  json.attributes do

    json.accepts_submissions_until  @assignment.accepts_submissions_until
    json.assignment_type_id         @assignment.assignment_type_id
    json.description                @assignment.description
    json.due_at                     @assignment.due_at
    json.full_points                @assignment.full_points
    json.id                         @assignment.id
    json.name                       @assignment.name
    json.pass_fail                  @assignment.pass_fail
    json.position                   @assignment.position
    json.purpose                    @assignment.purpose
    json.threshold_points           @assignment.threshold_points

    # boolean flags

    json.has_info             !@assignment.description.blank?
    json.has_levels           @assignment.assignment_score_levels.present?
    json.has_threshold        @assignment.threshold_points && @assignment.threshold_points > 0
    json.is_a_condition       @assignment.is_a_condition?
    json.is_due_in_future     @assignment.due_at.present? && @assignment.due_at >= Time.now
    json.is_earned_by_group   @assignment.grade_scope == "Group"
    json.is_required          @assignment.required
    json.is_rubric_graded     @assignment.grade_with_rubric?
  end

  # Assignment Score Levels

  if @assignment.assignment_score_levels.present?
    json.score_levels @assignment.assignment_score_levels do |asl|
      json.name asl.name
      json.points asl.points
    end
  end

  # conditions and keys

  if @assignment.unlock_conditions.present?

    unlock_conditions = @assignment.unlock_conditions.map do |condition|
      condition.requirements_description_sentence
    end
    json.unlock_conditions unlock_conditions

    unlocked_conditions = @assignment.unlock_conditions.map do |condition|
      condition.requirements_completed_sentence
    end
    json.unlocked_conditions unlocked_conditions

    # used in predictor front end to determine if any conditions are closed
    json.conditional_assignment_ids assignment.unlock_conditions.where(condition_type: "Assignment").pluck(:condition_id)
  end

  if @assignment.unlock_keys.present?
    unlock_keys = @assignment.unlock_keys.map do |key|
      key.key_description_sentence
    end
    json.unlock_keys unlock_keys
  end
end

json.meta do
  json.term_for_assignment term_for :assignment
  json.term_for_pass current_course.pass_term
  json.term_for_fail current_course.fail_term
end
