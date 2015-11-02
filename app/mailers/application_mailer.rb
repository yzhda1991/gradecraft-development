class ApplicationMailer < ActionMailer::Base
  SENDER_EMAIL = 'mailer@gradecraft.com'
  ADMIN_EMAIL = 'admin@gradecraft.com'
  SENDER = "GradeCraft <#{SENDER_EMAIL}>"
  default from: SENDER
  default template_path: -> (mailer) { "mailers/#{mailer.class.name.underscore}" }

  # private
  # def self.user_locale(user)
  #   user.try(:locale) || ENV['DEFAULT_LOCALE'] || :en
  # end
end
