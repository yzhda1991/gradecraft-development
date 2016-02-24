module Analytics
  # this is the default configuration module for Analytics. Any configuration
  # values that need to be modified on the system-wide configuration for
  # Analytics should have an attr_accessor value set here.
  class Configuration
    # all accessible configuration values
    attr_accessor :event_aggregates,
                  :default_granularity_options_for_select,
                  :default_range_options_for_select,
                  :exports

    # these are the default configuration values for Analytics
    # If you"d like to override these configuration values please do so in
    # /config/initializers/resque_job.rb or wherever the inititalizers are
    # stored in the application
    def initialize
      self.event_aggregates = {}
      self.default_granularity_options_for_select = Analytics::Aggregate::GRANULARITIES.keys[1..-1].collect{ |g| [g.to_s.titleize, g] }.unshift(["Auto", nil])
      self.default_range_options_for_select = [["Past Day", "past_day"], ["Past Week", "past_week"], ["Past Month", "past_month"], ["Past Year", "past_year"]]
      self.exports = []
    end
  end
end
