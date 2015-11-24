module Services
  module Actions
    class BuildsUser
      extend LightService::Action

      expects :attributes
      promises :user

      executed do |context|
        attributes = context[:attributes]
        context[:user] = User.new attributes
      end
    end

    class SavesUser
      extend LightService::Action

      executed do |context|
      end
    end
  end
end
