json.assignments @assignments do |assignment|
  cache ["v1", assignment] do
    next unless assignment.point_total > 0 || assignment.pass_fail?
    json.merge! assignment.attributes
    json.score_levels assignment.assignment_score_levels.map {|asl| {name: asl.name, value: asl.value}}
    json.fixed assignment.fixed?
    json.info ! assignment.description.blank?

    if assignment.current_student_grade
      assignment.current_student_grade.tap do |grade|
        cache ["v1", grade] do
          json.grade do
            json.id grade.id
            json.point_total grade.point_total
            json.predicted_score grade.predicted_score
            json.score grade.score
            json.pass_fail_status grade.pass_fail_status if assignment.pass_fail
          end
        end
      end
    end

    json.late assignment.past? && assignment.accepts_submissions && ! @student.submission_for_assignment(assignment).present? ? true : false
  end
end

json.term_for_assignment term_for :assignment
json.term_for_pass current_course.pass_term
json.term_for_fail current_course.fail_term
