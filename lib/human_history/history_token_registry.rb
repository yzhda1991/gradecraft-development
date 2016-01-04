module HumanHistory
  class HistoryTokenRegistry
    class << self
      def registered_tokens
        @registered_tokens ||= []
      end

      def clear
        registered_tokens.map(&:type).each { |type| unregister type }
      end

      def registered?(type)
        registered_tokens.map(&:type).include? type
      end

      def register(type, selector=nil)
        if selector.nil? && type.respond_to?(:tokenizable?)
          selector = ->(key, value, changeset) { type.tokenizable?(key, value, changeset) }
        end
        registered_tokens << RegisteredToken.new(type, selector) unless registered?(type)
      end

      def unregister(type)
        registered_tokens.delete_if { |registered_token| registered_token.type == type }
      end

      def for(key, value, changeset)
        registered_tokens.map do |registered_token|
          registered_token if registered_token.selector.call(key, value, changeset)
        end.delete_if(&:nil?)
      end
    end
  end
end
