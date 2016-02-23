require 'resque-retry'
require 'resque/errors'
require_relative 'event_logger/base'
require_relative 'event_logger/enqueue'

module EventLogger
  extend IsConfigurable
end
