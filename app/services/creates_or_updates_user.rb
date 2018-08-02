require "light-service"
require_relative "creates_or_updates_user/creates_or_updates_user"

module Services
  class CreatesOrUpdatesUser
    extend LightService::Organizer

    def self.call(attributes, course, send_welcome_email=false)
      with(attributes: attributes, course: course, send_welcome_email: send_welcome_email)
        .reduce(
          Actions::CreatesOrUpdatesUser
        )
    end
  end
end
