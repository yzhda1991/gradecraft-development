json.assignments @assignments do |assignment|
  json.merge! assignment.attributes
  json.grade = assignment.current_student_grade

  json.late assignment.past? && assignment.accepts_submissions && ! current_student.submission_for_assignment(assignment).present? ? true : false
end

