module ActiveLMS
  class InvalidProviderError < StandardError
    def initialize(provider)
      super "#{provider} is not a supported provider"
    end
  end
end
