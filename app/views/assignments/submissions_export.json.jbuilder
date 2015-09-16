json.root do |root|
  json.content_type ""

  root_files = [{
      path: "/assignments/#{@assignment.id}/export_grades.csv",
      content_type: "text/csv"
    }]
  json.files root_files do |file|
     json.path file[:path]
     json.content_type file[:content_type]
  end
end

@students.each do |student|
  name = "#{student.last_name}_#{student.first_name}"
  json.set! name do
    json.content_type "directory"
  end
end

#csv @assignment.grade_import(@students)


