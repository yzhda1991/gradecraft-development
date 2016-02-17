module EventLogger
  module Enqueue
    def initialize(attrs={})
      @attrs = attrs
    end
    attr_reader :attrs

    def logger_class
      self.class
    end

    def enqueue_in(time_until_start)
      Resque.enqueue_in(time_until_start, logger_class, event_type, attrs)
    end

    def enqueue_at(scheduled_time)
      Resque.enqueue_at(scheduled_time, logger_class, event_type, attrs)
    end

    def enqueue
      Resque.enqueue(logger_class, event_type, attrs)
    end
  end
end
