module Services
  module Actions
    class InternalizesUser
      extend LightService::Action

      expects :user

      executed do |context|
        user = context[:user]

        if user.internal?
          user.username = username_from_email(user.email) if user.username.blank?
          user.email = email_from_username(user.username) if user.email.blank?
          user.kerberos_uid = user.username
        end
      end

      private

      def self.email_from_username(username)
        "#{username}@umich.edu"
      end

      def self.username_from_email(email)
        email.split(/@/).first
      end
    end
  end
end
