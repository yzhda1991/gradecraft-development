module Services
  module Actions
    class InternalizesUser
      extend LightService::Action

      expects :user

      executed do |context|
        user = context[:user]
        user.kerberos_uid = user.username if user.internal?
      end
    end
  end
end
