require 'resque-retry'
require 'resque/errors'

module ResqueJob
  class Base
    # add resque-retry for all jobs
    extend Resque::Plugins::Retry
    
    # defaults
    @queue = :main # put all jobs in the 'main' queue
    @performer_class = ResqueJob::Performer
    @retry_limit = 3 # retry only 3 times
    @retry_delay = 60 # retry after 60 seconds
    @success_message = "The job successfully performed its work."
    @failure_message = "The job failed in the course of performing work."

    # perform block that is ultimately called by Resque
    def self.perform(attrs={})
      # mention to the logger that something is happening
      p @start_message

      # this is where the magic happens
      performer = @performer_class.new(self.class, attrs) # self.class is the job class
      performer.setup
      performer.do_the_work

      # mention to the logger how things went
      notify_event_outcome(performer.outcome.successful?)
    end

    # notifications
    def self.notify_event_outcome(job_successful?)
      puts (job_successful? ? @success_message : @failure_message)
    end

    def self.start_message
      @start_message || "Starting #{self.job_type} in queue #{@queue}."
    end

    def self.job_type
      self.class.to_s
    end

    # Inheritance Behaviors
   
    ## allow sub-classes to inherit class-level instance variables
    def self.inherited(subclass)
      self.instance_variable_names.each do |ivar|
        subclass.instance_variable_set(ivar, instance_variable_get(ivar))
      end
    end

    ## get a list of instance variable names for inheritance
    def self.instance_variable_names
      self.class_level_instance_variables.collect {|ivar_name, val| "@#{ivar_name}"}
    end

    ## for building instance variable names, property values not built yet
    def self.class_level_instance_variables
      {
        queue: :main,
        retry_limit: 3,
        retry_delay: 60,
        success_message: "The job successfully performed its work.",
        failure_message: "The job failed in the course of performing work."
      }   
    end

    # need to figure out how to integrate this more cleanly
    # def self.define_instance_variables
    #   self.class_level_instance_variables.each do |name, value|
    #     instance_variable_set("@#{name}", value)
    #   end
    # end
  end
end
