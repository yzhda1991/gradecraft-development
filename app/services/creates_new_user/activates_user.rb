module Services
  module Actions
    class ActivatesUser
      extend LightService::Action

      expects :user

      executed do |context|
        user = context[:user]
        user.activate! if user.internal? || context[:manually_activate] == true
      end
    end
  end
end
