json.data @assignments do |assignment|
  next unless assignment.full_points > 0 || assignment.pass_fail?
  next unless assignment.visible_for_student?(@student)
  next unless assignment.include_in_predictor?
  json.type "assignments"
  json.id assignment.id.to_s
  json.attributes do

    json.accepts_submissions_until  assignment.accepts_submissions_until
    json.assignment_type_id         assignment.assignment_type_id
    json.description                assignment.description
    json.due_at                     assignment.due_at
    json.full_points                assignment.full_points
    json.id                         assignment.id
    json.name                       assignment.name
    json.pass_fail                  assignment.pass_fail
    json.position                   assignment.position
    json.purpose                    assignment.purpose
    json.threshold_points           assignment.threshold_points

    # boolean flags

    json.has_been_unlocked    assignment.is_unlockable? && \
      assignment.is_unlocked_for_student?(@student)

    json.has_info             assignment.description.blank?

    json.has_levels           assignment.assignment_score_levels.present?

    json.has_submission       assignment.accepts_submissions? && \
      @student.submission_for_assignment(assignment).present?

    json.has_threshold        assignment.threshold_points && \
      assignment.threshold_points > 0

    json.is_a_condition       assignment.is_a_condition?

    json.is_accepting_submissions    assignment.accepts_submissions? && \
      !assignment.submissions_have_closed? && \
      !@student.submission_for_assignment(assignment).present?

    json.is_closed_without_submission    assignment.submissions_have_closed? && \
      !@student.submission_for_assignment(assignment).present?

    json.is_due_in_future     assignment.due_at.present? && assignment.due_at >= Time.now

    json.is_earned_by_group   assignment.grade_scope == "Group"

    json.is_late              assignment.overdue? && \
      assignment.accepts_submissions && \
      !@student.submission_for_assignment(assignment).present?

    json.is_locked            !assignment.is_unlocked_for_student?(@student)

    json.is_required          assignment.required

    json.is_rubric_graded     assignment.grade_with_rubric?

    if assignment.assignment_score_levels.present?
      json.score_levels assignment.assignment_score_levels do |asl|
        json.name asl.name
        json.points asl.points
      end
    end

    if assignment.unlock_conditions.present?
      json.unlock_conditions assignment.unlock_conditions do |condition|
        condition.requirements_description_sentence
      end
      json.unlocked_conditions assignment.unlock_conditions do |condition|
        condition.requirements_completed_sentence
      end
    end

    if assignment.unlock_keys.present?
     json.unlock_keys  assignment.unlock_keys.map do |key|
       key.key_description_sentence
     end
    end
  end
end

json.meta do
  json.term_for_assignment term_for :assignment
  json.term_for_pass current_course.pass_term
  json.term_for_fail current_course.fail_term
  json.update_assignments false
end
