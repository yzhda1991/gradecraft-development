require "./lib/showtime"

class AssignmentGroupPresenter < Showtime::Presenter
  def assignment
    properties[:assignment]
  end

  def group
    properties[:group]
  end

  def has_submission?
    !submission.nil?
  end

  def submission
    @submission ||= group.submission_for_assignment(assignment)
  end

  def title
    "#{group.name} Grades"
  end
end
