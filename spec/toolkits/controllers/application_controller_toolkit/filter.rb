module Toolkits
  module Controllers
    module ApplicationControllerToolkit
      module Filters

        def stub_current_user
          @current_user = double(:current_user).as_null_object
          allow(@current_user).to receive_messages(current_course: double(:course))
          allow(controller).to receive_messages(current_user: @current_user)
        end

      end
    end
  end
end
