require "light-service"
require_relative "sends_resource_email/send_email"

module Services
  class SendsResourceEmail
    extend LightService::Organizer

    def self.send_resource_email(user)
      with(user: user)
        .reduce(
          Actions::SendEmail
        )
    end
  end
end
