require "light-service"
require_relative "updates_user/updates_user"

module Services
  class UpdatesUser
    extend LightService::Organizer

    def self.update(attributes)
      with(attributes: attributes)
        .reduce(
          Actions::UpdatesUser
        )
    end
  end
end
