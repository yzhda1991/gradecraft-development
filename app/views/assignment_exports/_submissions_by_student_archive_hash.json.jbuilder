json.directory_name @presenter.export_file_name
json.files do [{ path: @presenter.csv_file_path, content_type: "text/csv" }]

json.sub_directories do
  @submissions_by_student.each do |student_with_submissions|
    json.directory_name student_with_submissions.first do # this is the "page_jimmy-45" key
    json.directories do
      student_with_submissions.last.each do |submission| # an array of submissions for the student
        json.files SubmissionFilesExporter.new(submission).directory_files
      end
    end
  end
end

## Example JSON:
# [
#   {
#     directory_name: "export directory name",
#     files: [
#       { path: "http://gradecraft.com/grades/8/grade_import_template.csv", content_type: "text/csv" }
#     ],
#     sub_directories: [
# 
#       {
#         directory_name: "page_jimmy-45",
#         sub_directories: [
# 
#           {
#             directory_name: "submission_2015-04-10--10:30:54",
#             files: [
#               { path: "https://gradecraft.aws.com/jgashdghf", content_type: "application/pdf" },
#               { path: "https://gradecraft.aws.com/hdsgfhsdfhdsfdksfk", content_type: "application/pdf" },
#               { content: "Lorem Ipsum.....", filename: "jimmy_page_submission.txt", content_type: "text" }
#             ]
#           }
#         ]
#       }
#     ]
#   }
# ]
