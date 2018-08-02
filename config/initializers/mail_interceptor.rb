class MailInterceptor
  def self.delivering_email(message)
    message.subject = "[#{Rails.env.upcase}] #{message.subject}"
    message.from = "Your friendly #{Rails.env} environment"
    message.to = message.to.map { |to| "#{to} <#{ENV["MAIL_INTERCEPTOR_RECIPIENT"]}>" } \
      if ENV["MAIL_INTERCEPTOR_RECIPIENT"].present?
  end
end

ActionMailer::Base.register_interceptor(MailInterceptor) if Rails.env.staging?
