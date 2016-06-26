module Analytics
  module Errors
    class InvalidParsingError < StandardError
      attr_reader :parsing_method, :export, :message

      def initialize(parsing_method:, export:, message: nil)
        @parsing_method = parsing_method
        @export = export
        @message = message
      end


        message ||= "The parsing method designated for parsing the given " \
                    "export method was neither a proc, nor a valid method " \
                    "on either the record itself, or the export class being " \
                    "used to define the export process. Please check the

    end
  end
end
