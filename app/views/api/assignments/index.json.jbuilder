json.data @assignments do |assignment|
  next unless assignment.full_points > 0 || assignment.pass_fail?
  next unless assignment.visible_for_student?(@student)
  next unless assignment.include_in_predictor?
  json.type "assignments"
  json.id assignment.id.to_s
  json.attributes do

    json.id                         assignment.id
    json.name                       assignment.name
    json.description                assignment.description
    json.purpose                    assignment.purpose
    json.accepts_submissions_until  assignment.accepts_submissions_until
    json.assignment_type_id         assignment.assignment_type_id
    json.due_at                     assignment.due_at
    json.pass_fail                  assignment.pass_fail
    json.full_points                assignment.full_points
    json.position                   assignment.position
    json.threshold_points           assignment.threshold_points

    # boolean flags

    json.has_been_unlocked assignment.is_unlockable? && assignment.is_unlocked_for_student?(@student)
    json.has_info
    json.has_levels
    json.has_submission
    json.has_threshold
    json.is_a_condition
    json.is_accepting_submissions
    json.is_closed_without_submission
    json.is_due_in_future
    json.is_earned_by_group
    json.is_late
    json.is_locked
    json.is_required
    json.is_rubric_graded



    json.score_levels assignment.assignment_score_levels.map do |asl|
      {name: asl.name, points: asl.points}
    end

    json.unlock_conditions assignment.unlock_conditions.map do |condition|
      condition.requirements_description_sentence
    end

    json.unlocked_conditions assignment.unlock_conditions.map do |condition|
      condition.requirements_completed_sentence
    end

    json.unlock_keys  assignment.unlock_keys.map do |key|
      key.key_description_sentence
    end
  end
end

json.meta do
  json.term_for_assignment term_for :assignment
  json.term_for_pass current_course.pass_term
  json.term_for_fail current_course.fail_term
  json.update_assignments false
end
