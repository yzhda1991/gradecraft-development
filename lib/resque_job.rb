require 'resque-retry'
require 'resque/errors'

module ResqueJob
  class Base
    extend Resque::Plugins::Retry
    
    # defaults
    @queue = :main # put all jobs in the 'main' queue
    @job_type = "basic resque job" # for use in logging etc.
    @retry_limit = 3 # retry only 3 times
    @retry_delay = 60 # retry after 60 seconds
    @start_message = "Starting #{@job_type} in queue #{@queue}."
    @success_message = "The job successfully performed its work."
    @failure_message = "The job failed in the course of performing work."

    # perform block that is ultimately called by Resque
    def self.perform(attrs={})
      p @start_message
      @outcome = self.start_work(attrs)
      notify_event_outcome(@outcome)
    end

    # this is where the heavy lifting is done
    def self.start_work(attrs={})
      puts "Please define a self.start_work() method on the inheritor class to do some work."
      { success: true } # pass this back to @job_succeeded
    end

    def self.notify_event_outcome(outcome)
      puts (self.job_successful(outcome) ? @success_message : @failure_message)
    end

    def self.job_successful?(outcome)
      outcome[:success] == true
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
        queue: :main,
        job_type: "basic resque job",
        retry_limit: 3,
        retry_delay: 60,
        start_message: "Starting #{@job_type} in queue #{@queue}.",
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
