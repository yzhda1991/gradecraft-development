class EventLogger
  extend Resque::Plugins::Retry
  @queue = :eventlogger
  @retry_limit = 3
  @retry_delay = 60

  def self.perform(event_type, data={})
    p "Starting EventLogger"
    attributes = {event_type: event_type, created_at: Time.now}
    Analytics::Event.create(attributes.merge(data))
  rescue Resque::TermException => e
    puts e.message
    puts e.backtrace.inspect
  end

  # allow sub-classes to inherit class-level instance variables
  def self.inherited(subclass)
    ["@retry_limit", "@retry_delay"].each do |ivar|
      subclass.instance_variable_set(ivar, instance_variable_get(ivar))
    end
  end
end
