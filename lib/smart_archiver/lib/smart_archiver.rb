require "smart_archiver/version"
require "json"

module SmartArchiver
  module Managers
    class Importer
      def initialize(request_json)
        @request_json = request_json
        @top_level_directory = SmartArchiver::Directory.new(request_json)
        parse_request_json
      end

      private

      def parse_request_json
      
      end
    end

    class Exporter
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

  class Directory
    def initialize(attrs={})
      @attrs = attrs
      @archive_name = attrs.keys.first
      @files = attrs[:files]
    end
  end

  module Parser
    class File
      def initialize(file_hashes)
        @file_hashes = file_hashes
      end
      attr_reader :file_hashes
    end

    class Directory
      def initialize(directory_hash)
        @directory_hash = directory_hash
        @directory_name = directory_hash.keys.first
      end
      attr_reader :directory_hashes
    end
  end

  class File
    def initialize(attrs={})
      @path = attrs[:path]
      @content_type= attrs[:content_type]
    end
    attr_reader :path, :content_type
  end

  module Compression
  end
end

## Example JSON:
# {
#   export-directory-name: {
#     files: [
#       { path: "http://gradecraft.com/grades/8/grade_import_template.csv", content_type: "text/csv" }
#     ],
#     directories: [
#       "page_jimmy-45": {
#         directories: [
#           "submission_2015-04-10--10:30:54": {
#             files: [
#               { path: "https://gradecraft.aws.com/jgashdghf", content_type: "application/pdf" },
#               { path: "https://gradecraft.aws.com/hdsgfhsdfhdsfdksfk", content_type: "application/pdf" },
#               { content: "Lorem Ipsum.....", filename: "jimmy_page_submission.txt", content_type: "text" }
#             ]
#           }
#         ]
#       }
#     ]
#   }
# }
