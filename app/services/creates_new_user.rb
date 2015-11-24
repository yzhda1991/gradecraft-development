require "light-service"
require_relative "creates_new_user/builds_user"
require_relative "creates_new_user/generates_password"

module Services
  class CreatesNewUser
    extend LightService::Organizer

    def self.create(attributes)
      with(attributes: attributes).reduce(
        Actions::BuildsUser,
        Actions::GeneratesPassword,
        Actions::SavesUser
      )
    end
  end
end
