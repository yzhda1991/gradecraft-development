json.assignments @assignments do |assignment|
  next unless assignment.point_total > 0 || assignment.pass_fail?
  next unless assignment.visible_for_student?(@student)
  next unless assignment.include_in_predictor?
  json.merge! assignment.attributes
  json.score_levels assignment.assignment_score_levels.map {|asl| {name: asl.name, value: asl.value}}

  # points earned is all or nothing
  json.fixed assignment.fixed?

  # boolean states for icons
  json.is_required assignment.required
  json.has_info ! assignment.description.blank?
  json.is_late assignment.past? && assignment.accepts_submissions && ! @student.submission_for_assignment(assignment).present? ? true : false
  json.is_earned_by_group assignment.grade_scope == "Group"

  json.is_locked ! assignment.is_unlocked_for_student?(@student)

  json.has_been_unlocked assignment.is_unlockable? && assignment.is_unlocked_for_student?(@student)
  if assignment.is_unlockable?
    json.unlock_conditions assignment.unlock_conditions.map{ |condition|
      "#{condition.name} must be #{condition.condition_state}"
    }
  end

  json.is_a_condition assignment.is_a_condition?
  if assignment.is_a_condition?
    json.unlock_keys assignment.unlock_keys.map{ |key|
      "#{key.unlockable.name} is unlocked by #{key.condition_state} #{key.condition.name}"
    }
  end

  # student's grade info inserted into each assignment
  # student's prediction info inserted into each grade
  if assignment.current_student_grade
    assignment.current_student_grade.tap do |grade|
      json.grade do
        json.id grade[:id]
        json.predicted_score grade[:predicted_score]
        json.score grade[:score]
        json.raw_score grade[:raw_score]
        json.pass_fail_status grade[:pass_fail_status] if assignment.pass_fail
      end
    end
  end
end

json.term_for_assignment term_for :assignment
json.term_for_pass current_course.pass_term
json.term_for_fail current_course.fail_term
json.update_assignments @update_assignments

json.student current_user.is_student?(current_course)
