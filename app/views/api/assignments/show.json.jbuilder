json.data do
  return if @assignment.reload.course != current_course

  json.partial! 'api/assignments/assignment', assignment: @assignment
end

json.included do
  if @assignment.assignment_files.present?
    json.array! @assignment.assignment_files do |assignment_file|
      json.type "file_uploads"
      json.id assignment_file.id.to_s
      json.attributes do
        json.id assignment_file.id
        json.assignment_id assignment_file.assignment_id
        json.filename assignment_file.filename
      end
    end
  end
end

json.meta do
  json.term_for_assignment term_for :assignment
  json.term_for_pass current_course.pass_term
  json.term_for_fail current_course.fail_term
end
