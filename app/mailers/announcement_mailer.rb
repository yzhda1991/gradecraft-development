class AnnouncementMailer < ActionMailer::Base
  def announcement_email(announcement, student)
    @announcement = announcement
    @student = student
    mail to: @student.email,
       from: "\"#{@announcement.author.public_name}\" <#{@announcement.author.email}>",
    subject: @announcement.title
  end
end
