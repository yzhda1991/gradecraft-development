module Services
  module Actions
    class UpdatesUser
      extend LightService::Action

      expects :attributes

      executed do |context|
        attributes = context[:attributes]
        id = attributes[:id]

        begin
          user = User.find id
        rescue ActiveRecord::RecordNotFound => e
          context.fail_with_rollback!(e.message, error_code: 404)
        end

        context.fail_with_rollback!("The user is invalid and cannot be saved", error_code: 422) \
          unless user.update_attributes attributes
        context[:user] = user
      end
    end
  end
end
