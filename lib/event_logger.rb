require 'resque-retry'
require 'resque/errors'

# this module is the initial declaration and entry point for the EventLogger
# library. It should be used for all system Resque jobs that directly interact
# with the Analytics library or log events. If you need to create a background
# job that doesn't interact with analytics or events it's probably best to use
# the ResqueJob library as it's behaviors are agnostic to how it's being used,
# whereas the EventLogger jobs presume interaction with event Analytics and
# logging to the Mongo backend
module EventLogger
  extend IsConfigurable
end

require_dependency 'is_configurable'
require_dependency 'event_logger/base'
require_dependency 'event_logger/configuration'
require_dependency 'event_logger/enqueue'
