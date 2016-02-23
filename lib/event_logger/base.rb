module EventLogger

  # This class is intended to be inherited by EventLogger subclasses that
  # interact directly with Resque in anyway. It implements multiple behaviors
  # such as advanced logging, retry, and interaction with the target
  # Analytics class that make it much easier to use this class as a base rather
  # than a naked class from which #perform is being called
  #
  # Almost all of the behavior here is intended for the use of this class as a
  # class constant to be passed into Resque and not as an object. If you'd like
  # more advanced enqueuing behaviors consider including EventLogger::Enqueue
  # or EventLogger::Params in your EventLogger::Base subclass
  #
  class Base
    extend Resque::Plugins::Retry
    extend Resque::Plugins::ExponentialBackoff
    extend LogglyResque # pulls in logger class method for logging to Loggly

    # pass designated ivars from #inheritable_ivars
    # down to descendent subclasses
    extend InheritableIvars

    # class-level instance variables for Resque interaction

    # this is the Resque queue in which jobs created from this class will
    # be enqueued to
    @queue = :event_logger

    # what to call the event when we're logging about it
    @event_name = "Event"

    # name of the target analytics class to use for logging the attrs
    # that are generated through the perform block
    @analytics_class = Analytics::Event

    @start_message = "Starting #{@queue.to_s.camelize}"
    @success_message = "#{@event_name} analytics record was" +
      "successfully created."
    @failure_message = "#{@event_name} analytics record failed to create."

    # instance methods
    def event_type
      "event"
    end

    # perform block that is ultimately called by Resque
    def self.perform( event_type, data={} )
      logger.info @start_message
      event = @analytics_class.create analytics_attrs(event_type, data)
      outcome = notify_event_outcome(event, data)
      logger.info outcome
    end

    # override the backoff strategy from Resque::ExponentialBackoff
    def self.backoff_strategy
      @backoff_strategy ||= EventLogger.configuration.backoff_strategy
    end

    def self.notify_event_outcome( event, data )
      if event.valid?
        success_message_with_data(data)
      else
        failure_message_with_data(data)
      end
    end

    def self.success_message_with_data( data )
      "#{@success_message} with data #{data}"
    end

    def self.failure_message_with_data( data )
      "#{@failure_message} with data #{data}"
    end

    def self.analytics_attrs( event_type, data={} )
      { event_type: event_type, created_at: Time.zone.now }.merge data
    end

    def self.inheritable_ivars
      [
        :queue,
        :event_name,
        :analytics_class,
        :start_message,
        :success_message,
        :failure_message
      ]
    end
  end
end
