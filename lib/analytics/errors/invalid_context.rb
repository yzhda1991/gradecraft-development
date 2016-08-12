module Analytics
  module Errors
    class InvalidContext < StandardError
      attr_reader :context_filter, :context

      def initialize(context_filter:, context:, message: nil)
        @context_filter = context_filter
        @context = context
        @message = message
      end

      def to_s
        message || default_message
      end

      def default_message
        "The context filter #{context_filter.inspect} does not accept export " \
          "contexts of class #{context.class.inspect} as valid. Please pass " \
          "only contexts of valid classes into the context filter, or add the " \
          "given context class to the list of valid context types."
      end
    end
  end
end
