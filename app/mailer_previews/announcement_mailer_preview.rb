class AnnouncementMailerPreview
  def announcement_email
    announcement = @announcement_id ?
      Announcement.find(@announcement_id) : Announcement.last
    student = @student_id ?
      User.find(@student_id) :
      User.with_role_in_course("student", announcement.course).first
    AnnouncementMailer.announcement_email announcement, student
  end
end
