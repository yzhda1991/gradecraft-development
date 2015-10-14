require 'resque-retry'
require 'resque/errors'

class EventLogger
  extend Resque::Plugins::Retry
  @queue = :eventlogger
  @retry_limit = 3
  @retry_delay = 60
  @start_message = "Starting EventLogger"
  @success_message = "Event was successfully created."
  @failure_message = "Event creation wasnot successful."

  # perform block that is ultimately called by Resque
  def self.perform(event_type, data={})
    p @start_message
    event = Analytics::Event.create self.event_attrs(event_type, data)
    notify_event_outcome(event)
  end

  def self.notify_event_outcome(event)
    puts (event.valid? ? @success_message : @failure_message)
  end

  def self.event_attrs(event_type, data)
    { event_type: event_type, created_at: Time.now }.merge data
  end

  # allow sub-classes to inherit class-level instance variables
  def self.inherited(subclass)
    self.instance_variable_names.each do |ivar|
      subclass.instance_variable_set(ivar, instance_variable_get(ivar))
    end
  end

  def self.instance_variable_names
    self.class_level_instance_variables.collect {|ivar_name, val| "@#{ivar_name}"}
  end

  def self.class_level_instance_variables
    {
      queue: :eventlogger,
      retry_limit: 3,
      retry_delay: 60,
      start_message: "Starting EventLogger",
      success_message: "Event was successfully created.",
      failure_message: "Event creation was not successful"
    }   
  end

  # need to figure out how to integrate this more cleanly
  # def self.define_instance_variables
  #   self.class_level_instance_variables.each do |name, value|
  #     instance_variable_set("@#{name}", value)
  #   end
  # end
end
