module EventLogger
  class Base
    extend Resque::Plugins::Retry
    extend Resque::Plugins::ExponentialBackoff

    # class-level instance variables for Resque interaction
    @queue = :event_logger
    @event_name = "Event"
    @analytics_class = Analytics::Event
    @backoff_strategy = [0, 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360, 420, 540, 660, 780, 900, 1140, 1380, 1520, 1760, 3600, 7200, 14400, 28800]

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
      event = @analytics_class.create self.event_attrs(event_type, data)
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

    def self.event_attrs(event_type, data)
      { event_type: event_type, created_at: Time.now }.merge data
    end

    def self.logger
      @logger ||= Logglier.new(self.logger_url, format: :json)
    end

    # https://logs-01.loggly.com/inputs/<loggly-token>/tag/tag-name
    def self.logger_url
      [ self.logger_base_url, ENV['LOGGLY_TOKEN'], "tag", self.queue_tag_name ].join("/")
    end

    def self.logger_base_url
      "https://logs-01.loggly.com/inputs"
    end

    def self.queue_tag_name
      "#{@queue.to_s.gsub(/_+/,'-')}-jobs-#{Rails.env}"
    end

    # allow sub-classes to inherit class-level instance variables
    def self.inherited(subclass)
      self.instance_variable_names.each do |ivar|
        subclass.instance_variable_set(ivar, instance_variable_get(ivar))
      end
    end

    def self.instance_variable_names
      self.inheritable_attributes.collect {|attr_name| "@#{attr_name}" }
    end

    def self.inheritable_attributes
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
