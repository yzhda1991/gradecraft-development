require_relative "submission_presenter"

class NewSubmissionPresenter < SubmissionPresenter
  def submission
    @submission ||= assignment.submissions.new
  end

  def student
    view_context.current_student
  end
end
