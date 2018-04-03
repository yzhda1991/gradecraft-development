json.data @students do |student|
  grade = student.grade_for_assignment @assignment
  submission = student.submission_for_assignment @assignment

  json.type "users"
  json.id student.id

  json.attributes do

    json.first_name student.first_name
    json.last_name student.last_name
    json.student_path student_path(student)

    json.weighted_assignments student.weighted_assignments? current_course

    # Assignment-related
    json.assignment_unlocked @assignment.is_unlocked_for_student? student

    # Grade-related
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

    # Submission-related
    json.submission_submitted_at submission.submitted_at unless submission.nil?

    # Paths
    json.grade_path grade_path(grade) if grade.persisted?
  end
end

json.meta do
  json.term_for_student term_for :student
end
