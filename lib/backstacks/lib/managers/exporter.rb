module Backstacks
  module Managers

    class Exporter
      def export
      end

      def response_json
       { message: response_message, code: response_code }
      end

      private

      def response_message
      end

      def response_code
      end
    end

  end
end
