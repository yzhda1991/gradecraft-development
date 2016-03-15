module EventLogger
  # This module should be included in classes that inherit from
  # EventLogger::Base, or really any class that you'd like to use for enqueuing
  # job behaviors without writing your own DSL for that process.
  #
  # The one caveat on using this on a class beside EventLogger::Base is that
  # Resque will expect a .perform method on the target class in the event that
  # the enqueue fails and the fallback is used.
  #
  # For reference the self.class.perform calls for the fallback here should
  # probably just replaced with a fallback method which can be overwritten
  # without having to overwrite either of the enqueue_with_fallback methods.
  module Enqueue
    def initialize(event_session = {})
      @event_session = event_session
    end
    attr_reader :event_session

    def logger_class
      self.class
    end

    def enqueue_in(time_until_start)
      Resque.enqueue_in(time_until_start, logger_class, event_type, event_attrs)
    end

    def enqueue_at(scheduled_time)
      Resque.enqueue_at(scheduled_time, logger_class, event_type, event_attrs)
    end

    def enqueue
      Resque.enqueue(logger_class, event_type, event_attrs)
    end

    def enqueue_with_fallback
      # schedule the event in the background if Resque is available
      enqueue
    rescue Redis::BaseError
      # otherwise perform the job directly
      fallback
    end

    def enqueue_in_with_fallback(time_until_start)
      # schedule the event for later if Resque is available
      enqueue_in(time_until_start)
    rescue Redis::BaseError
      # otherwise perform the job directly
      fallback
    end

    def fallback
      self.class.perform(event_type, event_attrs)
    end
  end
end
