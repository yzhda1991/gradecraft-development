module EventLogger
  class Base
    extend Resque::Plugins::Retry
    extend Resque::Plugins::ExponentialBackoff
    extend LogglyResque # pulls in logger class method for logging to Loggly
    extend InheritableIvars # pass designated ivars from #inheritable_ivars down to descendent subclasses

    # class-level instance variables for Resque interaction
    @queue = :event_logger
    @event_name = "Event"
    @analytics_class = Analytics::Event
    @backoff_strategy = EventLogger.configuration.backoff_strategy

    @start_message = "Starting #{@queue.to_s.camelize}"
    @success_message = "#{@event_name} analytics record was successfully created."
    @failure_message = "#{@event_name} analytics record failed to create."

    # instance methods
    def event_type
      "event"
    end

    # perform block that is ultimately called by Resque
    def self.perform(event_type, data={})
      self.logger.info @start_message
      event = @analytics_class.create self.analytics_attrs(event_type, data)
      outcome = notify_event_outcome(event, data)
      self.logger.info outcome
    end

    def self.notify_event_outcome(event, data)
      if event.valid?
        self.success_message_with_data(data)
      else
        self.failure_message_with_data(data)
      end
    end

    def self.success_message_with_data(data)
      "#{@success_message} with data #{data}"
    end

    def self.failure_message_with_data(data)
      "#{@failure_message} with data #{data}"
    end

    def self.analytics_attrs(event_type, data={})
      { event_type: event_type, created_at: Time.zone.now }.merge data
    end

    def self.inheritable_ivars
      [
        :queue,
        :event_name,
        :analytics_class,
        :backoff_strategy,
        :start_message,
        :success_message,
        :failure_message
      ]
    end
  end
end
