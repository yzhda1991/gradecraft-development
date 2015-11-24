module Services
  module Actions
    class SendsWelcomeEmail
      extend LightService::Action

      expects :send_welcome_email, :user

      executed do |context|
        send_welcome_email = context[:send_welcome_email]
        user = context[:user]

        UserMailer.welcome_email(user).deliver_now if send_welcome_email && user.activated?
      end
    end
  end
end
