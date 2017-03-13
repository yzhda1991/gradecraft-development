json.type "grades"
json.id   grade.id.to_s

json.attributes do
  json.id                         grade.id
  json.assignment_id              grade.assignment_id
  json.student_id                 grade.student_id
  json.student_name               grade.student.name
  json.group_id                   grade.group_id
  json.feedback                   grade.feedback
  json.status                     grade.status
  json.raw_points                 grade.raw_points
  json.pass_fail_status           grade.pass_fail_status
  json.adjustment_points          grade.adjustment_points
  json.final_points               grade.final_points
  json.adjustment_points_feedback grade.adjustment_points_feedback
  json.updated_at                 grade.updated_at
end

json.relationships do
  if grade.file_uploads.present?
    json.file_uploads do
      json.data grade.file_uploads do |file_upload|
        json.type "file_uploads"
        json.id file_upload.id.to_s
      end
    end
  end

  if grade.criterion_grades.present?
    json.criterion_grades do
      json.data grade.criterion_grades do |criterion_grade|
        json.type "criterion_grades"
        json.id criterion_grade.id.to_s
      end
    end
  end
end
