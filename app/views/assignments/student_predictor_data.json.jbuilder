json.assignments @assignments do |assignment|
  next unless assignment.point_total > 0 || assignment.pass_fail?
  json.merge! assignment.attributes
  json.score_levels assignment.assignment_score_levels.map {|asl| {name: asl.name, value: asl.value}}
  json.info ! assignment.description.blank?

  if assignment.current_student_grade
    assignment.current_student_grade.tap do |grade|
      json.grade do
        json.id grade.id
        json.status grade.status
        json.predicted_score grade.predicted_score
        json.score grade.graded_points
        json.pass_fail_status grade.graded_pass_fail_status
      end
    end
  end

  json.late assignment.past? && assignment.accepts_submissions && ! current_student.submission_for_assignment(assignment).present? ? true : false
end

json.term_for_assignment term_for :assignment
json.term_for_pass current_course.pass_term
json.term_for_fail current_course.fail_term
