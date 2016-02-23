module ResqueJob
  class Configuration
    attr_accessor :backoff_strategy

    def initialize
      self.backoff_strategy = []
    end
  end
end
