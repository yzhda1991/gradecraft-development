json.data do
  json.type "grades"
  json.id   @grade.id.to_s

  json.attributes do
    json.id                         @grade.id
    json.assignment_id              @grade.assignment_id
    json.student_id                 @grade.student_id
    json.feedback                   @grade.feedback
    json.status                     @grade.status
    json.adjustment_points          @grade.adjustment_points
    json.adjustment_points_feedback @grade.adjustment_points_feedback
  end

  json.relationships do
    if @grade_files.present?
      json.grade_files do
        json.data @grade_files do |grade_file|
          json.type "grade_files"
          json.id grade_file.id.to_s
        end
      end
    end
  end
end

json.included do
  if @grade_files.present?
    json.array! @grade_files do |grade_file|
      json.type "grade_files"
      json.id grade_file.id.to_s
      json.attributes do
        json.id grade_file.id
        json.grade_id grade_file.grade_id
        json.filename grade_file.filename
        json.filepath grade_file.filepath
        json.file_processing grade_file.file_processing
      end
    end
  end
end

json.meta do
  json.grade_status_options @grade_status_options
  json.threshold_points     @grade.assignment.threshold_points
end

