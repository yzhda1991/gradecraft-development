require_relative "submission_presenter"

class EditSubmissionPresenter < SubmissionPresenter
  def id
    properties[:id]
  end

  def submission
    assignment.submissions.find(id)
  end

  def student
    submission.student
  end
end
