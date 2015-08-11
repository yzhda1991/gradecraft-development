class AnnouncementMailer < ActionMailer::Base
  def announcement_email(announcement, student)
    mail to: student.email,
       from:  announcement.author.email
  end
end
