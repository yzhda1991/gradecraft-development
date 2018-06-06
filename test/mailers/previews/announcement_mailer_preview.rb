class AnnouncementMailerPreview < ActionMailer::Preview
  def announcement_email
    @course = Course.first
    @student = User.with_role_in_courses("student", @course).first
    @announcement = Announcement.create(title: "Hey", body: "Now", author: User.first, recipient: @student, course: @course)
    AnnouncementMailer.announcement_email @announcement, @student
  end
end
