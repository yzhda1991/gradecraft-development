require 'resque-retry'
require 'resque/errors'

module ResqueJob
  class Base
    # add resque-retry for all jobs
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
      # mention to the logger that something is happening
      p @start_message

      # this is where the magic happens
      job = self.class.new(attrs)
      job.setup_work
      job.do_the_work
      job.cleanup_work

      # mention to the logger how things went
      notify_event_outcome(job.was_successful?)
    end

    # this is where the heavy lifting is done
    def do_the_work(attrs={})
      puts "Please define a self.start_work() method on the inheritor class to do some work."
      { success: true } # pass this back to @job_succeeded
    end

    # mock out some empty work callback methods just in case
    def before_the_work; end
    def after_the_work; end

    # notifications
    def self.notify_event_outcome(job_successful?)
      puts (job_successful? ? @success_message : @failure_message)
    end

    # DSL improvements and resque-scheduler helpers
    def initialize(attrs={})
      @attrs = attrs
    end

    def enqueue_in(time_until_start)
      Resque.enqueue_in(time_until_start, self.class, @attrs)
    end

    def enqueue_at(scheduled_time)
      Resque.enqueue_at(scheduled_time, self.class, @attrs)
    end

    def enqueue
      Resque.enqueue(self.class, @attrs)
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
