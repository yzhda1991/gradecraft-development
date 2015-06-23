json.assignments @assignments do |assignment|
  json.merge! assignment.attributes
  json.late assignment.past? && assignment.accepts_submissions && ! current_student.submission_for_assignment(assignment).present? ? true : false
end

json.grades @grades do |grade|
  json.merge! grade.attributes
  # grade should only be available to students once the status is "Graded"
  json.point_total grade.status == "Graded" ? grade.point_total : nil
end
