require_relative '../test_helper'
require_relative '../../app/workers/event_loggers/pageview_event_logger'

class PageviewLoggerTest
  def initialize
    @pageview_logger = PageviewEventLogger.new(pageview_logger_attrs)
  end

  def run_enqueue(count)
    count.times { @pageview_logger.enqueue }
  end

  def run_enqueue_in(time_until_run, count)
    count.times { @pageview_logger.enqueue_in(time_until_run) }
  end

  def run_enqueue_at(run_at_time, count)
    count.times { @pageview_logger.enqueue_at(run_at_time) }
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
