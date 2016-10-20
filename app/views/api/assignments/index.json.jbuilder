json.data @assignments do |assignment|
  next unless assignment.full_points > 0 || assignment.pass_fail?
  next unless !@student.present? || assignment.visible_for_student?(@student)
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

    json.has_info             !assignment.description.blank?
    json.has_levels           assignment.assignment_score_levels.present?
    json.has_threshold        assignment.threshold_points && assignment.threshold_points > 0
    json.is_a_condition       assignment.is_a_condition?
    json.is_due_in_future     assignment.due_at.present? && assignment.due_at >= Time.now
    json.is_earned_by_group   assignment.grade_scope == "Group"
    json.is_required          assignment.required
    json.is_rubric_graded     assignment.grade_with_rubric?

    if @student.present?
      json.has_been_unlocked \
        assignment.is_unlockable? && assignment.is_unlocked_for_student?(@student)

      json.has_submission \
        assignment.accepts_submissions? &&
        @student.submission_for_assignment(assignment).present?

      json.is_accepting_submissions \
        assignment.accepts_submissions? &&
        !assignment.submissions_have_closed? &&
        !@student.submission_for_assignment(assignment).present?

      json.is_late \
        assignment.overdue? && assignment.accepts_submissions &&
        !@student.submission_for_assignment(assignment).present?

      json.is_closed_without_submission \
        assignment.submissions_have_closed? &&
        !@student.submission_for_assignment(assignment).present?

      json.is_locked !assignment.is_unlocked_for_student?(@student)

    # booleans for generic predictor
    else
      json.is_locked false
      json.has_been_unlocked false
      json.has_submission false
      json.is_accepting_submissions \
        assignment.accepts_submissions? && !assignment.submissions_have_closed?
      json.is_late \
        assignment.overdue? && assignment.accepts_submissions
      json.is_closed_without_submission false
    end

    # Assignment Score Levels

    if assignment.assignment_score_levels.present?
      json.score_levels assignment.assignment_score_levels do |asl|
        json.name asl.name
        json.points asl.points
      end
    end

    # conditions and keys

    if assignment.unlock_conditions.present?
      unlock_conditions = assignment.unlock_conditions.map do |condition|
        condition.requirements_description_sentence
      end
      json.unlock_conditions unlock_conditions

      unlocked_conditions = assignment.unlock_conditions.map do |condition|
        condition.requirements_completed_sentence
      end
      json.unlocked_conditions unlocked_conditions
    end

    if assignment.unlock_keys.present?
      unlock_keys = assignment.unlock_keys.map do |key|
        key.key_description_sentence
      end
      json.unlock_keys unlock_keys
    end
  end

  json.relationships do
    if @predicted_earned_grades.present? && @predicted_earned_grades.where(assignment_id: assignment.id).present?
      json.prediction data: {
        type: "predicted_earned_grades",
        id: @predicted_earned_grades.where(assignment_id: assignment.id).first.id.to_s
      }
    end

    if @grades.present? && @grades.where(assignment_id: assignment.id).present?
      grade =  @grades.where(assignment_id: assignment.id).first
      if GradeProctor.new(grade).viewable?(@student)
        json.grade data: { type: "grades", id: grade.id.to_s }
      end
    end
  end
end

json.included do
  if @predicted_earned_grades.present?
    json.array! @predicted_earned_grades do |predicted_earned_grade|
      json.type "predicted_earned_grades"
      json.id predicted_earned_grade.id.to_s
      json.attributes do
        json.id predicted_earned_grade.id
        json.predicted_points predicted_earned_grade.predicted_points
      end
    end
  end

  if @grades.present?
    json.array! @grades do |grade|
      next unless GradeProctor.new(grade).viewable?(@student)
      json.type "grades"
      json.id grade.id.to_s
      json.attributes do
        json.id             grade.id
        json.score          grade.score
        json.final_points   grade.final_points
        json.is_excluded    grade.excluded_from_course_score?
        json.pass_fail_status grade.pass_fail_status
      end
    end
  end
end

json.meta do
  json.term_for_assignment term_for :assignment
  json.term_for_pass current_course.pass_term
  json.term_for_fail current_course.fail_term
  json.allow_updates @allow_updates
end
