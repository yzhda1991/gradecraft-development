class AnnouncementMailer < ApplicationMailer
  layout "mailers/notification_layout"

  def announcement_email(announcement, student)
    @announcement = announcement
    @student = student
    @email_title = "GradeCraft Announcement"

    mail to: @student.email,
       from: "\"#{@announcement.author.name}\" <#{@announcement.author.email}>",
    subject: @announcement.title
  end
end
