class ApplicationMailer < ActionMailer::Base
  SENDER_EMAIL = 'mailer@gradecraft.com'
  ADMIN_EMAIL = 'admin@gradecraft.com'
  SENDER = "GradeCraft <#{SENDER_EMAIL}>"

  default from: SENDER
  default layout: -> (mailer) { template_path(mailer) }
  default template_path: -> (mailer) { default_layout(mailer) }

  private

  # @mz todo: add specs for these
  def template_path(mailer)
    mailer_name(mailer).gsub(/_mailer/,"")
  end

  def default_layout(mailer)
    "mailers/#{mailer_name(mailer)}"
  end

  def mailer_name(mailer)
    mailer.class.name.underscore
  end

  # def self.user_locale(user)
  #   user.try(:locale) || ENV['DEFAULT_LOCALE'] || :en
  # end
end
