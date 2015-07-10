json.assignments @assignments do |assignment|
  next unless assignment.point_total > 0 || assignment.pass_fail?
  json.merge! assignment.attributes
  json.grade = assignment.current_student_grade

  json.late assignment.past? && assignment.accepts_submissions && ! current_student.submission_for_assignment(assignment).present? ? true : false
end

json.term_for_assignment = term_for :assignment
