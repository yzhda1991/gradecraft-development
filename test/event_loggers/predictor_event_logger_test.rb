require_relative '../test_helper'

class PredictorLoggerTest
  def initialize
    @pageview_logger = PredictorEventLogger.new(pageview_logger_attrs)
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
      user_role: "student",
      page: "/a/great/path",
      created_at: Time.parse("Jan 20 1972"),
      assignment_id: 20,
      score: 50000,
      possible: 60000,
      created_at: Time.now
    }
  end
end
