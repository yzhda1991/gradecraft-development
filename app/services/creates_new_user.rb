require "light-service"
require_relative "creates_new_user/builds_user"
require_relative "creates_new_user/generates_password"
require_relative "creates_new_user/internalizes_user"
require_relative "creates_new_user/saves_user"

module Services
  class CreatesNewUser
    extend LightService::Organizer

    def self.create(attributes)
      with(attributes: attributes).reduce(
        Actions::BuildsUser,
        Actions::GeneratesPassword,
        Actions::InternalizesUser,
        Actions::SavesUser
      )
    end
  end
end
