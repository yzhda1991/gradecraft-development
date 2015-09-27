module Backstacks
  module Managers

    class ImportManager
      def initialize(request_json)
        @request_json = request_json
        @top_level_directory = Backstacks::Directory.new(request_json)
        parse_request_json
      end

      private

      def parse_request_json
      
      end
    end

  end
end
