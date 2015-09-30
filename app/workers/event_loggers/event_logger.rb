class EventLogger
  extend Resque::Plugins::Retry
  @queue = :eventlogger
  @retry_limit = 3
  @retry_delay = 60
  @start_message = "Starting EventLogger"

  def self.perform(event_type, data={})
    p @start_message
    Analytics::Event.create self.event_attrs(event_type, data)
  rescue Resque::TermException => e
    puts e.message
    puts e.backtrace.inspect
  end

  def self.event_attrs(event_type, data)
    { event_type: event_type, created_at: Time.now }.merge data
  end

  # allow sub-classes to inherit class-level instance variables
  def self.inherited(subclass)
    ["@retry_limit", "@retry_delay", "@start_message"].each do |ivar|
      subclass.instance_variable_set(ivar, instance_variable_get(ivar))
    end
  end
end
