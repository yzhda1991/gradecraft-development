json.data @students do |student|
  grade = student.grade_for_assignment @assignment
  submission = student.submission_for_assignment @assignment
  team = student.team_for_course current_course

  json.type "users"
  json.id student.id

  json.attributes do
    json.id student.id
    json.first_name student.first_name
    json.last_name student.last_name
    json.full_name student.name
    json.student_path student_path(student)

    json.weighted_assignments student.weighted_assignments? current_course

    # Assignment-related
    json.assignment_unlocked @assignment.is_unlocked_for_student? student

    # Grade-related
    json.grade_id grade.id if grade.persisted?
    json.grade_score points(grade.score)
    json.grade_raw_score points(grade.raw_points)
    json.grade_final_points points(grade.final_points)
    json.grade_instructor_modified grade.instructor_modified?
    json.grade_pass_fail_status term_for(grade.pass_fail_status) unless grade.pass_fail_status.nil?
    json.grade_level @assignment.grade_level(grade)
    json.grade_complete grade.complete?
    json.grade_student_visible grade.student_visible?
    json.grade_feedback_read grade.feedback_read?
    json.grade_feedback_reviewed grade.feedback_reviewed?
    json.grade_not_released grade.not_released?

    json.team_id student.team.id unless student.team.nil?

    # Submission-related
    json.submission_exists submission.present?
    json.submission_submitted_at l submission.submitted_at unless submission.nil?
    json.submission_visible Assignments::Presenter.new(assignment: @assignment).has_viewable_submission? student, current_user

    # Paths
    if grade.persisted?
      json.grade_path grade_path(grade)
      json.edit_grade_link edit_grade_link_to(grade)
    end
    json.assignment_submission_path assignment_submission_path(@assignment, submission) unless submission.nil?
    json.assignment_student_grade_path assignment_student_grade_path(@assignment, student, team_id: (team.nil? ? nil : team.id))
  end
end

json.meta do
  json.term_for_student term_for :student
end
