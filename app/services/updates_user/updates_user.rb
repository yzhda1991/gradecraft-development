module Services
  module Actions
    class UpdatesUser
      extend LightService::Action

      expects :attributes, :user

      executed do |context|
        attributes = context[:attributes]
        email = attributes[:email]

        context.fail_with_rollback!("The user is invalid and cannot be saved", error_code: 422) \
          unless context.user.update_attributes attributes
      end
    end
  end
end
