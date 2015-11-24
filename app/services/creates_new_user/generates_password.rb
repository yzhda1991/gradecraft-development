module Services
  module Actions
    class GeneratesPassword
      extend LightService::Action

      expects :user

      executed do |context|
        user = context[:user]
        user.password = Sorcery::Model::TemporaryToken.generate_random_token unless user.internal?
      end
    end
  end
end
