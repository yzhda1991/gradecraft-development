module Services
  module Actions
    class MarkUserAsReceivedResources
      extend LightService::Action

      expects :user

      executed do |context|
        user = context[:user]
        if !user.received_resources
          user.received_resources = true
          user.save
        end
      end
    end
  end
end
