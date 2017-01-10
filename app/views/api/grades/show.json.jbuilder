json.data do
  json.type "grades"
  json.id   @grade.id.to_s

  json.attributes do
    json.id                         @grade.id
    json.assignment_id              @grade.assignment_id
    json.student_id                 @grade.student_id
    json.feedback                   @grade.feedback
    json.status                     @grade.status
    json.raw_points                 @grade.raw_points
    json.pass_fail_status           @grade.pass_fail_status
    json.adjustment_points          @grade.adjustment_points
    json.final_points               @grade.final_points
    json.is_custom_value            @grade.is_custom_value
    json.adjustment_points_feedback @grade.adjustment_points_feedback
    json.updated_at                 @grade.updated_at
  end

  json.relationships do
    if @grade.file_uploads.present?
      json.file_uploads do
        json.data @files_attachments do |file_upload|
          json.type "file_uploads"
          json.id file_upload.id.to_s
        end
      end
    end

    if @grade.criterion_grades.present?
      json.criterion_grades do
        json.data @grade.criterion_grades do |criterion_grade|
          json.type "criterion_grades"
          json.id criterion_grade.id.to_s
        end
      end
    end
  end
end

json.included do
  if @grade.file_uploads.present?
    json.array! @grade.file_uploads do |file_upload|
      json.type "file_uploads"
      json.id file_upload.id.to_s
      json.attributes do
        json.id file_upload.id
        json.grade_id file_upload.grade_id
        json.filename file_upload.filename
        json.filepath file_upload.filepath
        json.file_processing file_upload.file_processing
      end
    end
  end

  if @grade.criterion_grades.present?
    json.array! @grade.criterion_grades do |criterion_grade|
      json.type "criterion_grades"
      json.id criterion_grade.id.to_s
      json.attributes do
        json.id             criterion_grade.id
        json.grade_id       criterion_grade.grade_id
        json.assignment_id  criterion_grade.assignment_id
        json.points         criterion_grade.points
        json.criterion_id   criterion_grade.criterion_id
        json.level_id       criterion_grade.level_id
        json.student_id     criterion_grade.student_id
        json.comments       criterion_grade.comments
      end
    end
  end
end

json.meta do
  json.grade_status_options @grade_status_options
  json.threshold_points     @grade.assignment.threshold_points
  json.is_rubric_graded     @grade.assignment.grade_with_rubric?
end

