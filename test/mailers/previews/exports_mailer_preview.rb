class ExportsMailerPreview < ActionMailer::Preview
  
  def grade_export
    @course = Course.first
    ExportsMailer.grade_export(
      @course,
      user = User.first,
      course.assignments.to_csv
    )
    
    @course = Course.first
    @student = User.with_role_in_course("student", @course).first
    @announcement = Announcement.create(title: "Hey", body: "Now", author: User.first, recipient: @student, course: @course)
    AnnouncementMailer.announcement_email @announcement, @student
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
