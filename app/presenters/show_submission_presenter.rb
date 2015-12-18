require_relative "submission_presenter"

class ShowSubmissionPresenter < SubmissionPresenter
  def id
    properties[:id]
  end

  def submission
    assignment.submissions.find(id)
  end

  def student
    submission.student
  end

  def title
    if assignment.is_individual?
      name = student.first_name
    else
      name = group.name
    end
    "#{name}'s #{assignment.name} Submission (#{view_context.points assignment.point_total} #{"point".pluralize(assignment.point_total)})"
  end
end
