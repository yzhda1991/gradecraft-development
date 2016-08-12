module Analytics
  module Export
    class ContextFilter
      attr_reader :context

      def initialize(context: context)
        @context = context
        validate_context
        self
      end

      def self.valid_contexts(*context_class_names)
        @valid_contexts = context_class_names
      end

      def validate_context
        return true if valid_context?
        raise Analytics::Errors::InvalidContext \
          context: context,
          context_filter: self
      end

      def valid_context?
        class.valid_contexts.include? context.class.to_s.tableize
      end
    end
  end
end
