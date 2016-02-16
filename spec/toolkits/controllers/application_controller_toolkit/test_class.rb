module Toolkits
  module Controllers
    module ApplicationControllerToolkit
      module TestClass

        class ApplicationControllerFilterTest < ApplicationController
          def html_page
            respond_to do |format|
              format.html { render text: "<div>page loaded</div>", response: 200 }
            end
          end

          def json_page
            respond_to do |format|
              format.json { render json: { waffles: ["blueberry", "strawberry"]}, response: 200 }
            end
          end
        end

      end
    end
  end
end
