module Analytics
  module Errors
    class InvalidParsingError < StandardError
      attr_reader :parsing_method, :record, :export, :message

      def initialize(parsing_method:, record:, export:, message: nil)
        @parsing_method = parsing_method
        @record = record
        @export = export
        @message = message
      end

      def to_s
        message || default_message
      end

      def default_message
        "The parsing method #{parsing_method.inspect} as defined in the " \
          "export mapping: #{export.class.export_mapping.inspect} was neither" \
          "a proc nor a valid method on either the #{record.class.inspect}, " \
          "or the #{export.class.inspect} export class defining the export " \
          "process. Please check the parsing method to ensure that this is " \
          "a valid behavior for any of these entities."
      end

    end
  end
end
