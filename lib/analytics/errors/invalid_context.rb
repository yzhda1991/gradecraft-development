module Analytics
  module Errors
    class InvalidContextType < StandardError
      attr_reader :context_filter, :context

      def initialize(context_filter:, context_type:, message: nil)
        @context_filter = context_filter
        @context_type = context_type
        @message = message
      end

      def to_s
        message || default_message
      end

      def default_message
        "The context filter #{context_filter.inspect} does not accept export " \
          "contexts of type #{context_type.inspect}. Please pass " \
          "only valid context types into the context filter, or add the " \
          "given context type to accepts_context_types on the filter class."
      end
    end
  end
end
