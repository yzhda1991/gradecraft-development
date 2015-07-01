json.assignments @assignments do |assignment|
  json.merge! assignment.attributes
  json.late assignment.past? && assignment.accepts_submissions && ! current_student.submission_for_assignment(assignment).present? ? true : false
  json.grades @grades do |grade|
    json.point_total grade.status == "Graded" ? grade.point_total : nil
  end
end
