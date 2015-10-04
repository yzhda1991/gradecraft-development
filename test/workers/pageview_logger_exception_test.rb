require_relative '../../app/workers/event_loggers/pageview_event_logger'

class PageviewLoggerWithExceptions < PageviewEventLogger
  @queue = :pageview_logger_with_exceptions
  @retry_limit = 3
  @retry_delay = 60
  @start_message = "Starting PageviewEventLogger with exceptions"

  def self.perform(event_type, data={})
    p @start_message
    p "event_type: #{event_type}"
    begin
      Analytics::Event.create self.event_attrs(event_type, data)
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

class PageviewLoggerWithExceptionsTest
  def initialize
    @pageview_logger_with_exceptions = PageviewLoggerWithExceptions.new(pageview_logger_attrs)
  end

  def run_enqueue(count)
    count.times { @pageview_logger_with_exceptions.enqueue }
  end

  def run_enqueue_in(time_until_run, count)
    count.times { @pageview_logger_with_exceptions.enqueue_in(time_until_run) }
  end

  def run_enqueue_at(run_at_time, count)
    count.times { @pageview_logger_with_exceptions.enqueue_at(run_at_time) }
  end

  def pageview_logger_attrs
    {
      course_id: 50,
      user_id: 70,
      student_id: 90,
      user_role: "great role",
      page: "/a/great/path",
      created_at: Time.parse("Jan 20 1972")
    }
  end
end
