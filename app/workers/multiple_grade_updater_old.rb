class MultipleGradeUpdatePerformer < ResqueJob::Performer
  def setup
    @grade_ids = @attrs[:grade_ids]
    @grades = fetch_grades_with_assignment
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    @grades.each do |grade|
      require_success { grade.save_student_and_team_scores }

      if grade.assignment.notify_released?
        require_success { NotificationMailer.grade_released(grade.id).deliver_now }
      end
    end
  end

  def outcome_messages
    if outcome_success?
      puts "All grades saved and notified correctly."
    elsif outcome_failure?
      puts "All grades and notifications failed."
    else
      puts "Some grades and notifications succeeded but others failed."
    end
  end

  protected

  def fetch_grades_with_assignment
    Grade.where(id: grade_ids).includes(:assignment).load
  end

  def notify_grade_released(grade)
    NotificationMailer.grade_released(grade.id).deliver
  end
end

class MultipleGradeUpdaterJob < ResqueJob::Base
  @queue = :multiple_grade_updater
  @performer_class = MultipleGradeUpdatePerformer
end
