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


    # perform block that is ultimately called by Resque
    def self.perform(attrs={})
      # TODO: catch everything with an exception, log the exception message, and then throw another exception
      # mention to the logger that something is happening

      # TODO: need to add specs for the new begin/resque
      begin
        logger = self.logger
        # build a new background job logger
        # puts "@peformer_class: #{@performer_class}"
        # puts @logger
        puts this_message = self.start_message(attrs) # this wasn't running because 
        # @logger.info this_message
        logger.info this_message
        # log_message "This is retry ##{@retry_attempt}" if @retry_attempt > 0 # add specs for this
        #
        # this is where the magic happens
        performer = @performer_class.new(attrs) # self.class is the job class
        performer.do_the_work

        # mention to the logger how things went
        # performer.log_outcome_messages(@logger) # todo: add specs for logger
        # combined_outcome_messages(@logger) # todo: add specs for logger

        performer.outcomes.each do |outcome|
          logger.info "SUCCESS: #{outcome.message}" if outcome.success?
          logger.info "FAILURE: #{outcome.message}" if outcome.failure?
          logger.info "RESULT: #{outcome.result_excerpt}"
        end
      rescue Exception => e
        logger.info "Error in #{@performer_class.to_s}: #{e.message}"
        puts "Error in #{@performer_class.to_s}: #{e.message}"
        # puts e.backtrace.inspect
        logger.info e.backtrace
        # puts e.backtrace.inspect
        raise ResqueJob::Errors::ForcedRetryError
      end
    end
    attr_reader :attrs # TODO: add spec for this

    def initialize(attrs={})
      @attrs = attrs
    end

    def self.logger
      @logger ||= Logglier.new(self.logger_url, format: :json)
    end

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

    # def self.combined_outcome_messages(performer)
    #   performer.outcomes.each do |outcome|
    #     outcome_messages = []
    #     outcome_messages << "SUCCESS: #{outcome.message}" if outcome.success?
    #     outcome_messages << "FAILURE: #{outcome.message}" if outcome.failure?
    #     outcome_messages << "RESULT: " + "#{outcome.result}"[0..100].split("\n").first
    #     final_message = outcome_messages.join(" | ")
    #     puts final_message
    #     @logger.info final_message
    #   end
    # end

    def enqueue_in(time_until_start)
      Resque.enqueue_in(time_until_start, self.object_class, @attrs)
    end

    def enqueue_at(scheduled_time)
      Resque.enqueue_at(scheduled_time, self.object_class, @attrs)
    end

    def enqueue
      Resque.enqueue(self.object_class, @attrs)
    end

    # todo: modify specs for this
    def self.start_message(attrs)
      @start_message || "Starting #{self.job_type} in queue '#{@queue}' with attributes { #{self.perform_attributes(attrs)} }."
    end

    def self.perform_attributes(attrs)
      attrs.collect do |key, value|
        "#{key}: #{value}"
      end.join(", ")
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
        performer_class: ResqueJob::Performer,
        retry_limit: 3,
        retry_delay: 60
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
