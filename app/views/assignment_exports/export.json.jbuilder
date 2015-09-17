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

@submissions_by_student.each do |sbs|
  json.set! sbs[0] do
    json.content_type "directory"
    files = []
    sbs[1].each do |submission|
      if submission.text_comment.present? or submission.link.present?
        student = submission.student
        filename = "#{student.last_name}_#{student.first_name}_#{@assignment.name.gsub(/\W+/, "_").downcase[0..20]}_submission_text.txt"
        contents = "Submission items from #{student.last_name}, #{student.first_name}\n"
        contents += "\ntext comment: #{submission.text_comment}\n" if submission.text_comment.present?
        contents += "\nlink: #{submission.link }\n" if submission.link.present?
        files << { content: contents, name: filename, content_type: "text" }
      end
      if submission.submission_files
        submission.submission_files.each do |sf|
          files << { path: sf.url, content_type: sf.content_type }
        end
      end
    end
    json.files files
  end
end

## Example JSON:

# {
#   root: {
#     content_type: "",
#     files: [
#       { path: "http://gradecraft.com/grades/8/grade_import_template.csv", content_type: "text/csv" }
#     ]
#   },
#   jimmy_page: {
#     content_type: "directory",
#     files: [
#       { path: "https://gradecraft.aws.com/jgashdghf", content_type: "application/pdf" },
#       { path: "https://gradecraft.aws.com/hdsgfhsdfhdsfdksfk", content_type: "application/pdf" },
#       { content: "Lorem Ipsum.....", name: "jimmy_page_submission.txt", content_type: "text" }
#     ]
#   }
# }
