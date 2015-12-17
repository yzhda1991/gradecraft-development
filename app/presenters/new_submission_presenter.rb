require_relative "submission_presenter"

class NewSubmissionPresenter < SubmissionPresenter
  def submission
    @submission ||= assignment.submissions.new
  end
end
