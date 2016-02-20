module EventLogger
  module Enqueue
    def initialize(event_session={})
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
      begin
        # schedule the event in the background if Resque is available
        enqueue
      rescue
        # otherwise insert directly into Mongo
        self.class.perform(event_type, event_attrs)
      end
    end

    def enqueue_in_with_fallback(time_until_start)
      begin
        # schedule the event for later if Resque is available
        enqueue_in(time_until_start)
      rescue
        # otherwise insert directly into Mongo
        self.class.perform(event_type, event_attrs)
      end
    end

    # this is the default attribute set for EventLogger classes
    # should be extended in #event_attrs inside of child classes for better
    # granularity when more specific attributes are needed.
    #
    # Ideally this will be reorganized data from #event_session into a hash that's
    # persistable in Mongo or whatever the back-end event store is
    def base_attrs
      @base_attrs ||= { created_at: Time.zone.now }
    end

    # this is set in the event that the base attributes are all that's
    # needed by the target class
    def event_attrs
      base_attrs
    end
  end
end
