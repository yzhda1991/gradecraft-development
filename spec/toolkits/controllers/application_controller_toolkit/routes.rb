module Toolkits
  module Controllers
    module ApplicationControllerToolkit
      module Routes

        def define_event_logging_test_routes
          Rails.application.routes.draw do
            get "/html_page", to: "application_controller_event_logging_test#html_page"
            get "/json_page", to: "application_controller_event_logging_test#json_page"
            root to: "application_controller_event_logging_test#html_page"
          end
        end

      end
    end
  end
end
