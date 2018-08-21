require "light-service"
require_relative "creates_new_user/activates_user"
require_relative "creates_new_user/sends_welcome_email"

module Services
  class ActivatesUser
    extend LightService::Organizer

    def self.call(user)
      with(user: user, manually_activate: true, send_welcome_email: true).reduce(
        Actions::ActivatesUser,
        Actions::SendsWelcomeEmail
      )
    end
  end
end
