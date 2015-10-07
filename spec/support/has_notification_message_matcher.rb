require "rspec/expectations"

module GradeCraft
  module Matchers
    module Integration
      class NotificationMessages
        attr_reader :message, :name

        def initialize(name, message)
          @name = name
          @message = message
        end

        def matches?(page)
          Capybara.string(page.body).has_selector? ".alert-box.#{name}", text: message
        end

        def failure_message
          "expected the page to have a #{name} notification with the message \"#{message}\", but it was not found"
        end

        def failure_message_when_negated
          "expected the page to not have a #{name} notification with the message \"#{message}\", but it was found"
        end
      end

      def have_notification_message(name, message)
        NotificationMessages.new(name, message)
      end

      def have_error_message(message)
        have_notification_message :error, message
      end
    end
  end
end
