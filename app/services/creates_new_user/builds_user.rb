module Services
  module Actions
    class BuildsUser
      extend LightService::Action

      expects :attributes
      promises :user

      executed do |context|
        attributes = context[:attributes]
        context[:user] = User.new attributes
        user = context[:user]
        user.email = user.email.downcase
      end
    end
  end
end
