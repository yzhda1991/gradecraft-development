require_relative "../creates_new_user"
require_relative "../updates_user"
require_relative "../updates_user_for_course"

module Services
  module Actions
    class CreatesOrUpdatesUser
      extend LightService::Action

      expects :attributes, :send_welcome_email

      executed do |context|
        attributes = context[:attributes]
        email = attributes[:email].to_s.downcase

        if email.blank?
          context.fail! "Email can't be blank", 422
          next context
        end

        if User.email_exists? email
          course = context[:course]
          if course.nil?
            context.add_to_context Services::UpdatesUser.update(attributes)
          else
            context.add_to_context Services::UpdatesUserForCourse.update(attributes, course)
          end
        else
          send_welcome_email = attributes[:send_welcome_email]
          context.add_to_context Services::CreatesNewUser.create(attributes, send_welcome_email)
        end
      end
    end
  end
end
