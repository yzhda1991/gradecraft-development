require_relative "../creates_new_user"
require_relative "../updates_user"

module Services
  module Actions
    class CreatesOrUpdatesUser
      extend LightService::Action

      expects :attributes, :course, :send_welcome_email

      executed do |context|
        attributes = context[:attributes]
        entered_email = attributes[:email]
        email = entered_email.downcase

        if email.blank?
          context.fail! "Email can't be blank", 422
          next context
        end

        if User.email_exists? email
          course = context[:course]
          context.add_to_context Services::UpdatesUser.update(attributes, course)
        else
          send_welcome_email = attributes[:send_welcome_email]
          context.add_to_context Services::CreatesNewUser.create(attributes, send_welcome_email)
        end
      end
    end
  end
end
