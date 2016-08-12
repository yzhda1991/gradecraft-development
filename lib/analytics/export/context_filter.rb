module Analytics
  module Export
    class ContextFilter
      attr_reader :context

      def initialize(context: context)
        @context = context
        validate_context_type
        self
      end

      def self.accepts_context_types(*valid_context_types)
        @valid_context_types = valid_context_types
      end

      def validate_context_type
        return true if valid_context_type?
        raise Analytics::Errors::InvalidContextType \
          context_filter: self,
          context_type: context_type
      end

      def valid_context_type?
        class.valid_context_types.include? context_type
      end

      def context_type
        context.class.to_s.underscore.to_sym
      end
    end
  end
end
