require "is_configurable"
require_relative "analytics/configuration"
require_relative "analytics/event"
require_relative "analytics/aggregate"
require_relative "analytics/data"
require_relative "analytics/export"
require_relative "analytics/login_event"
require_relative "analytics/errors"

module Analytics
  extend IsConfigurable
end
