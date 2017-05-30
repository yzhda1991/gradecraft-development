module ActiveLMS
  class Configuration
    attr_reader :providers

    def initialize
      @providers = ProviderCollection.new
    end

    def provider(provider, &block)
      @providers << Provider.new(provider, &block)
    end

    private

    class ProviderCollection < Array
      def [](provider)
        self.find { |p| p.provider == provider }
      end
    end

    class Provider
      attr_reader :provider
      attr_accessor :client_id, :client_secret, :client_options, :base_uri

      def initialize(provider, &block)
        @provider = provider
        block.call(self) if block_given?
      end
    end
  end
end
