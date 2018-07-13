class ApplicationMailer < ActionMailer::Base
  SENDER_EMAIL = "mailer@gradecraft.com"
  ADMIN_EMAIL = "admin@gradecraft.com"
  ADMIN_GROUP_EMAIL = "gradecraft-admins@umich.edu"
  SENDER = "GradeCraft <#{SENDER_EMAIL}>"

  default from: SENDER

  private

  def default_layout(mailer)
    "mailers/" + mailer_name(mailer).gsub(/_mailer/,"_layout")
  end

  def mailer_name(mailer)
    mailer.class.name.underscore
  end
end
