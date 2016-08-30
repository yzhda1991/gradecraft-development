module Analytics
  module Errors
    class InvalidParsingStrategy < StandardError
      attr_reader :parsing_strategy, :record, :export

      def initialize(parsing_strategy:, record:, export:, message: nil)
        @parsing_strategy = parsing_strategy
        @record = record
        @export = export
        @message = message
      end

      def to_s
        @message || default_message
      end

      def default_message
        "The parsing strategy #{parsing_strategy.inspect} was neither " \
          "a proc nor a valid strategy on either the #{record.class.inspect}, " \
          "or the #{export.class.inspect} export class defining the export " \
          "process. Please check the parsing strategy to ensure that this is " \
          "a valid behavior for any of these entities."
      end

    end
  end
end
