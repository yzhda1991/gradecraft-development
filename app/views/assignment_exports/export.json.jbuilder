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
    json.files files
  end
end

## Example JSON:

{
  export-directory-name: {
    files: [
      { path: "http://gradecraft.com/grades/8/grade_import_template.csv", content_type: "text/csv" }
    ],
    directories: [
      jimmy_page: {
        files: [
          { path: "https://gradecraft.aws.com/jgashdghf", content_type: "application/pdf" },
          { path: "https://gradecraft.aws.com/hdsgfhsdfhdsfdksfk", content_type: "application/pdf" },
          { content: "Lorem Ipsum.....", filename: "jimmy_page_submission.txt", content_type: "text" }
        ]
      }
    ]
  }
}
