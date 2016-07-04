# this module is the initial declaration and entry point for the ResqueJob
# library. It should be used for all system Resque jobs that don't directly
# interact with the Analytics library or log events. In those instances the
# similar EventLogger library should be used since it's tailored to
# specifically handling jobs that are responsible for logging events in mongo
#
require "is_configurable"
require_relative "resque_job/base"
require_relative "resque_job/configuration"
require_relative "resque_job/outcome"
require_relative "resque_job/performer"
require_relative "resque_job/step"
require_relative "resque_job/errors/forced_retry_error"

module ResqueJob
  extend IsConfigurable
end

