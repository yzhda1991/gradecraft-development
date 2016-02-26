module Analytics
  extend IsConfigurable
end

require_dependency "is_configurable"
require_dependency "analytics/configuration"
require_dependency "analytics/event"
require_dependency "analytics/aggregate"
require_dependency "analytics/data"
