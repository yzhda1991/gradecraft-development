module Services
  module Actions
    class UpdatesUser
      extend LightService::Action

      expects :attributes

      executed do |context|
        attributes = context[:attributes]
        email = attributes[:email]

        user = User.find_by_insensitive_email email
        context.fail_with_rollback!("User could not be found", error_code: 404) if user.nil?

        context.fail_with_rollback!("The user is invalid and cannot be saved", error_code: 422) \
          unless user.update_attributes attributes
        context[:user] = user
      end
    end
  end
end
