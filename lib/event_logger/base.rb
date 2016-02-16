module EventLogger
  class Base
    extend Resque::Plugins::Retry
    extend Resque::Plugins::ExponentialBackoff

    @queue = :eventlogger
    @event_type = "event" # this should be downcased
    @backoff_strategy = [0, 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360, 420, 540, 660, 780, 900, 1140, 1380, 1520, 1760, 3600, 7200, 14400, 28800]

    @start_message = "Starting EventLogger"
    @success_message = "#{@event_type.capitalize} analytics record was successfully created."
    @failure_message = "#{@event_type.capitalize} analytics record failed to create."

    # perform block that is ultimately called by Resque
    def self.perform(event_type, data={})
      logger = self.logger
      logger.info @start_message
      event = Analytics::Event.create self.event_attrs(event_type, data)
      outcome = notify_event_outcome(event, data)
      logger.info outcome
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

    # @mz todo: add specs
    # these all need to be spec'd out
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
      self.inheritable_attributes.collect {|ivar_name| "@#{ivar_name}" }
    end

    def self.inheritable_attributes
      [
        :queue,
        :backoff_strategy,
        :start_message,
        :success_message,
        :failure_message,
        :event_type
      ]
    end
  end
end
