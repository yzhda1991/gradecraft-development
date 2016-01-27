require "light-service"
require_relative "creates_or_updates_user/create_or_update_user"

module Services
  class CreatesOrUpdatesUser
    extend LightService::Organizer

    def self.create_or_update(attributes, course, send_welcome_email=false)
      with(attributes: attributes, course: course, send_welcome_email: send_welcome_email)
        .reduce(
        Actions::CreateOrUpdateUser
      )
    end
  end
end
