class AnnouncementMailer < ApplicationMailer
  def announcement_email(announcement, student)
    @announcement = announcement
    @student = student
    @email_title = "GradeCraft Annoucement"

    mail to: @student.email,
       from: "\"#{@announcement.author.public_name}\" <#{@announcement.author.email}>",
    subject: @announcement.title
  end
end
