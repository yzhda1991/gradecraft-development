class ApplicationMailer < ActionMailer::Base
  SENDER_EMAIL = 'mailer@gradecraft.com'
  ADMIN_EMAIL = 'admin@gradecraft.com'
  SENDER = "GradeCraft <#{SENDER_EMAIL}>"

  default from: SENDER
  default layout: -> (mailer) { mailer_name.gsub(/_mailer/,"") }
  default template_path: -> (mailer) { "mailers/#{mailer_name}" }

  private

  def mailer_name
    mailer.class.name.underscore
  end

  # def self.user_locale(user)
  #   user.try(:locale) || ENV['DEFAULT_LOCALE'] || :en
  # end
end
