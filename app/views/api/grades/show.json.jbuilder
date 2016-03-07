json.data do
  json.type "grades"
  json.id   @grade.id.to_s

  json.attributes do
    json.id                         @grade.id
    json.assignment_id              @grade.assignment_id
    json.student_id                 @grade.student_id
    json.feedback                   @grade.feedback
    json.status                     @grade.status
    json.points_adjustment          @grade.points_adjustment
    json.points_adjustment_feedback @grade.points_adjustment_feedback
  end
end

json.meta do
  json.grade_status_options @grade_status_options
end

