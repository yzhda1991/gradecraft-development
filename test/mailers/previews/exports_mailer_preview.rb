class ExportsMailerPreview < ActionMailer::Preview
  
  def grade_export
    course = Course.first
    ExportsMailer.grade_export(
      course,
      user = User.first,
      course.assignments.to_csv
    )
  end
  
  def gradebook_export
    course = Course.first
    ExportsMailer.gradebook_export(
      course,
      User.first,
      "gradebook export", # export type
      course.assignments.to_csv
    )
  end
end
