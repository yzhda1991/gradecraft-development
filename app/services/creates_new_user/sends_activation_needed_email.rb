module Services
  module Actions
    class SendsActivationNeededEmail
      extend LightService::Action

      expects :user

      executed do |context|
        user = context[:user]

        UserMailer.activation_needed_email(user).deliver_now unless user.activated?
      end
    end
  end
end
