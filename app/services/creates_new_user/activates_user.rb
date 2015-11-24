module Services
  module Actions
    class ActivatesUser
      extend LightService::Action

      expects :user

      executed do |context|
        user = context[:user]
        user.activate! if user.internal?
      end
    end
  end
end
