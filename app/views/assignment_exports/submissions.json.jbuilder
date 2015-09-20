json.array! @presenter.submissions_grouped_by_student.sort do |student_array|
  json.directory_name student_array.first
  json.array! student_array.last do |submission|
    json.(submission, :id, :assignment_id, :student_id)
  end
end

