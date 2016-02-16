module EventLogger
  module Enqueue
    attr_reader :event_type

    def initialize(attrs={})
      @attrs = attrs
    end

    def enqueue_in(time_until_start)
      Resque.enqueue_in(time_until_start, self.class, @event_type, @attrs)
    end

    def enqueue_at(scheduled_time)
      Resque.enqueue_at(scheduled_time, self.class, @event_type, @attrs)
    end

    def enqueue
      Resque.enqueue(self.class, @event_type, @attrs)
    end
  end
end
