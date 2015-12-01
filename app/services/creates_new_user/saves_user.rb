module Services
  module Actions
    class SavesUser
      extend LightService::Action

      expects :user

      executed do |context|
        user = context[:user]
        context.fail_with_rollback!("The user is invalid and cannot be saved") \
          unless user.save
      end
    end
  end
end
