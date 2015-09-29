class GradeUpdater
  extend Resque::Plugins::Retry
  @retry_limit = 3
  @retry_delay = 60

  @queue= :gradeupdater

  def self.perform(grade_id)
  	p "Starting GradeUpdater"
  	begin
	    grade = Grade.where(id: grade_id).includes(:assignment).load.first
	    grade.save_student_and_team_scores
	    if grade.assignment.notify_released?
	      NotificationMailer.grade_released(grade.id).deliver
	    end
    rescue Resque::TermException => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end
