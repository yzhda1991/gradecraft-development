module ResqueJob

  # this is the default configuration module for ResqueJob. Any configuration
  # values that need to be modified on the system-wide configuration for
  # ResqueJob should have an attr_accessor value set here.
  class Configuration

    # all accessible configuration values
    attr_accessor :backoff_strategy

    # these are the default configuration values for ResqueJob
    # If you'd like to override these configuration values please do so in
    # /config/initializers/resque_job.rb or wherever the inititalizers are
    # stored in the application
    def initialize
      self.backoff_strategy = []
    end

  end
end
