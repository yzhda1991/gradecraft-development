require "light-service"
require_relative "updates_user/updates_user"

module Services
  class UpdatesUser
    extend LightService::Organizer

    def self.update(attributes, course)
      with(attributes: attributes, course: course)
        .reduce(
        Actions::UpdatesUser
      )
    end
  end
end
