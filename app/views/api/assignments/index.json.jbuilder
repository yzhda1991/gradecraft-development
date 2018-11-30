json.data @assignments do |assignment|
  next unless !@student.present? || assignment.visible_for_student?(@student)

  json.partial! 'api/assignments/assignment', assignment: assignment
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
