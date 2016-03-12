class GradeExportPreview
  def grade_export
    course = Course.first
    user = User.first
    csv_data = course.assignments.to_csv
    ExportsMailer.grade_export course, user, csv_data
  end
end