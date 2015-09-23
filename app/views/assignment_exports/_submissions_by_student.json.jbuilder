json.array! presenter.sorted_student_directory_keys do |student_key|
  json.directory_name student_key
  json.submissions presenter.submissions_grouped_by_student[student_key] do |submission|
    json.(submission, :id, :assignment_id, :student_id)
  end
end
