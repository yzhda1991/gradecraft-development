class ScoreRecalculator
  extend Resque::Plugins::Retry
  @retry_limit = 3
  @retry_delay = 60

  @queue= :scorerecalculator

  def self.perform(student_id, course_id)
  	p "Starting ScoreRecalculator"
  	begin
    	student = User.find(student_id)
    	student.cache_course_score(course_id)
    rescue Resque::TermException => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end
