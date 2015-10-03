require_relative './event_logger'
require 'resque/plugins/waiting_room'

class PageviewEventLogger < EventLogger
  # include the waiting room plugin
  extend Resque::Plugins::WaitingRoom

  # queue name
  @queue= :pageview_event_logger

  # message that posts to the log when being queued
  @start_message = "Starting PageviewEventLogger"

  # call from Waiting Room to throttle number of times performed
  can_be_performed times: 10, period: 1

  def initialize(attrs={})
    @attrs = attrs
  end

  def enqueue_in(time_until_start)
    Resque.enqueue_in(time_until_start, self.class, @attrs)
  end

  def enqueue_at(scheduled_time)
    Resque.enqueue_in(elapsed_time, self.class, @attrs)
  end

  def enqueue
    Resque.enqueue(self.class, @attrs)
  end
end
