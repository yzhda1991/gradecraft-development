require "light-service"
require_relative "sends_resource_email/send_email"
require_relative "sends_resource_email/mark_user_as_received_resources"

module Services
  class SendsResourceEmail
    extend LightService::Organizer

    def self.call(user)
      with(user: user)
        .reduce(
          Actions::SendEmail,
          Actions::MarkUserAsReceivedResources
        )
    end
  end
end
