require_relative "show_submission_presenter"

class EditSubmissionPresenter < ShowSubmissionPresenter
  def title
    if view_context.current_user.is_student?(course)
      "Editing My Submission for #{assignment.name}"
    else
      if assignment.has_groups?
        "Editing #{group.name}'s Submission"
      else
        "Editing #{student.name}'s Submission"
      end
    end
  end
end
