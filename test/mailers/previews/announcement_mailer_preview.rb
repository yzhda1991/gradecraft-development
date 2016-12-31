class AnnouncementMailerPreview < ActionMailer::Preview
  def announcement_email
    @course = Course.create(name: "Videogames and Learning", course_number: "101")
    @student = User.create(first_name: "Hermione", last_name: "Granger", username: "padfoot", email: "hermione@hogwarts.edu")
    @announcement = Announcement.create(title: "Hey", body: "Now", author: User.first, recipient: @student, course: @course)
    AnnouncementMailer.announcement_email @announcement, @student
  end
end
