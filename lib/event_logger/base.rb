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
    extend InheritableIvars # pass designated ivars from #inheritable_ivars down to subclasses

    # this is the Resque queue in which jobs created from this class will
    # be enqueued to
    @queue = :event_logger

    def base_attrs
      { event_type: event_type, created_at: Time.now }.freeze
    end

    def event_type
      self.class.to_s.underscore
    end

    class << self
      attr_reader :queue

      def event_name
        queue.to_s.camelize
      end

      # perform block that is ultimately called by Resque
      def perform(event_type, data = {})
        logger.info "Starting #{event_name} with data #{data}"
        event = analytics_class.create data.merge(event_type: event_type)
        logger.info event_outcome_message(event, data)
      end

      # override the backoff strategy from Resque::ExponentialBackoff
      def backoff_strategy
        @backoff_strategy ||= EventLogger.configuration.backoff_strategy
      end

      def event_outcome_message(event, data)
        message = event.valid? ? success_message : failure_message
        "#{message} with data #{data}"
      end

      def analytics_class
        # name of the target analytics class to use for logging the attrs
        # that are generated through the perform block
        #
        Analytics::Event
      end

      def success_message
        "#{event_name} analytics record was successfully created"
      end

      def failure_message
        "#{event_name} analytics record failed to create"
      end

      def inheritable_ivars
        [ :queue ].freeze
      end

      def logger
        Rails.logger
      end
    end
  end
end
