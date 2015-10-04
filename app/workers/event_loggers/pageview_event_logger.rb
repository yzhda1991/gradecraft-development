require_relative './event_logger'
require 'resque-retry'
require 'resque/errors'

class PageviewEventLogger < EventLogger
  extend Resque::Plugins::Retry

  # queue name
  @queue= :pageview_event_logger
  @retry_limit = 3
  @retry_delay = 5

  # message that posts to the log when being queued
  @start_message = "Starting PageviewEventLogger"

  def self.perform(event_type, data={})
    p @start_message
    p "event_type: #{event_type}"
    begin
      raise Exception
    rescue Exception => e
      puts e.message
      puts e.backtrace.inspect
    end
  end

  def initialize(attrs={})
    @attrs = attrs
  end

  def enqueue_in(time_until_start)
    Resque.enqueue_in(time_until_start, self.class, 'pageview', @attrs)
  end

  def enqueue_at(scheduled_time)
    Resque.enqueue_in(elapsed_time, self.class, 'pageview', @attrs)
  end

  def enqueue
    Resque.enqueue(self.class, 'pageview', @attrs)
  end
end
