require "light-service"
require_relative "creates_new_user/activates_user"
require_relative "creates_new_user/builds_user"
require_relative "creates_new_user/generates_password"
require_relative "creates_new_user/generates_usernames"
require_relative "creates_new_user/saves_user"
require_relative "creates_new_user/sends_activation_needed_email"
require_relative "creates_new_user/sends_welcome_email"

module Services
  class CreatesNewUser
    extend LightService::Organizer

    def self.call(attributes, send_welcome_email=false)
      with(attributes: attributes, send_welcome_email: send_welcome_email, manually_activate: attributes[:password].present?)
        .reduce(actions)
    end

    def self.actions
      [
        Actions::BuildsUser,
        reduce_if(-> (context) { context.user.password.blank? }, [Actions::GeneratesPassword]),
        Actions::GeneratesUsernames,
        Actions::SavesUser,
        Actions::ActivatesUser,
        Actions::SendsActivationNeededEmail,
        Actions::SendsWelcomeEmail
      ]
    end
  end
end
