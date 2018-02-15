module Services
  module Actions
    class SendEmail
      extend LightService::Action

      expects :user

      executed do |context|
        user = context[:user]
        if !user.received_resources
          UserMailer.umich_resources_email(user).deliver_now if Rails.env.production?
          UserMailer.app_resources_email(user).deliver_now if Rails.env.beta?
        end
      end
    end
  end
end
