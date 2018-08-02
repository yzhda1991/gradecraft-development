require_relative "../creates_new_user"
require_relative "../updates_user"
require_relative "../updates_user_for_course"

module Services
  module Actions
    class CreatesOrUpdatesUser
      extend LightService::Action

      expects :attributes, :send_welcome_email

      executed do |context|
        attributes = context.attributes
        email = attributes[:email].to_s
        username = attributes[:username].to_s

        if email.blank? && username.blank?
          context.fail! "Email and username cannot be blank", 422
          next context
        end

        find_and_set_user_context context, email, username
        if context[:user].nil?
          context.add_to_context Services::CreatesNewUser.call attributes, context.send_welcome_email
        else
          course = context[:course]
          if course.nil?
            context.add_to_context Services::UpdatesUser.call context[:user], attributes
          else
            context.add_to_context Services::UpdatesUserForCourse.call context[:user], attributes, course
          end
        end
      end

      private

      def self.find_and_set_user_context(context, email, username)
        user = User.find_by_insensitive_email email
        user ||= User.find_by_insensitive_username username
        context[:user] = user unless user.nil?
      end
    end
  end
end
