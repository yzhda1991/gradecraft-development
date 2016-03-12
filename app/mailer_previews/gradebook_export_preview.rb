class GradebookExportPreview
  def gradebook_export
    course = Course.first
    user = User.first
    export_type = "gradebook export"
    csv_data = course.assignments.to_csv
    ExportsMailer.gradebook_export course, user, export_type, csv_data
  end
end