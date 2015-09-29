class MultipleGradeUpdater
  extend Resque::Plugins::Retry
  @retry_limit = 3
  @retry_delay = 60

  @queue= :multiplegradeupdater

  def self.perform(grade_ids)
    puts "Starting MultipleGradeUpdater"
    begin
      grades = Grade.where(id: grade_ids).includes(:assignment).load
      grades.each do |grade|
        grade.save_student_and_team_scores
          if grade.assignment.notify_released?
            NotificationMailer.grade_released(grade.id).deliver_now
          end
        end
    rescue Resque::TermException => e
      puts e.message
      puts e.backtrace.inspect
    end
  end
end
