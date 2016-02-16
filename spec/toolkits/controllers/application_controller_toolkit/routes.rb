module Toolkits
  module Controllers
    module ApplicationControllerToolkit
      module Routes

        def define_filters_test_routes
          Rails.application.routes.draw do
            get '/html_page', to: 'application_controller_filters_test#html_page'
            get '/json_page', to: 'application_controller_filters_test#json_page'
            root to: 'application_controller_filters_test#html_page'
          end
        end

      end
    end
  end
end
