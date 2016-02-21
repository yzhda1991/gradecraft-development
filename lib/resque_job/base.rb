require "resque-retry"
require "resque/errors"

# mz todo: move a lot of this logic into an ApplicationJob file in /app/background_jobs
module ResqueJob
  class Base
    # add resque-retry for all jobs
    extend Resque::Plugins::Retry
    extend Resque::Plugins::ExponentialBackoff
    extend LogglyResque # pulls in logger class method for logging to Loggly

    # defaults
    @queue = :main # put all jobs in the 'main' queue
    @performer_class = ResqueJob::Performer
    @backoff_strategy = [0, 15, 30, 45, 60, 90, 120, 150, 180, 240, 300, 360, 420, 540, 660, 780, 900, 1140, 1380, 1520, 1760, 3600, 7200, 14400, 28800]

    class << self
      attr_reader :performer_class, :queue
    end

    # perform block that is ultimately called by Resque
    def self.perform(attrs={})
      begin
        logger.info self.start_message(attrs)

        # this is where the magic happens
        performer = @performer_class.new(attrs, logger) # self.class is the job class
        performer.do_the_work

        performer.outcomes.each do |outcome|
          logger.info "SUCCESS: #{outcome.message}" if outcome.success?
          logger.info "FAILURE: #{outcome.message}" if outcome.failure?
          logger.info "RESULT: #{outcome.result_excerpt}"
        end
      rescue Exception => e
        logger.info "Error in #{@performer_class.to_s}: #{e.message}"
        logger.info e.backtrace
        raise ResqueJob::Errors::ForcedRetryError
      end
    end
    attr_reader :attrs

    def initialize(attrs={})
      @attrs = attrs
    end

    def enqueue_in(time_until_start)
      Resque.enqueue_in(time_until_start, self.object_class, @attrs)
    end

    def enqueue_at(scheduled_time)
      Resque.enqueue_at(scheduled_time, self.object_class, @attrs)
    end

    def enqueue
      Resque.enqueue(self.object_class, @attrs)
    end

    def self.start_message(attrs)
      @start_message || "Starting #{self.job_type} in queue '#{@queue}' with attributes #{attrs}."
    end

    def self.object_class
      self.new.class
    end

    def object_class
      self.class
    end

    def self.job_type
      self.new.class.name
    end

    ## Inheritance Behaviors

    # allow sub-classes to inherit class-level instance variables
    def self.inherited(subclass)
      self.instance_variable_names.each do |ivar|
        subclass.instance_variable_set(ivar, instance_variable_get(ivar))
      end
    end

    # get a list of instance variable names for inheritance
    def self.instance_variable_names
      self.inheritable_attributes.collect {|attr_name| "@#{attr_name}" }
    end

    def self.inheritable_attributes
      [
        :queue,
        :performer_class,
        :backoff_strategy
      ]
    end

  end
end
