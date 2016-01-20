require_relative "../models/history_filter"
require_relative "submission_presenter"

class ShowSubmissionPresenter < SubmissionPresenter
  def id
    properties[:id]
  end

  def grade
    assignment.grades.where(student_id: student.id).first
  end

  def submission
    assignment.submissions.find(id)
  end

  def submission_grade_history
    HistoryFilter.new(submission.historical_merge(grade))
      .remove("name" => "admin_notes")
      .remove("name" => "feedback_read")
      .remove("name" => "feedback_read_at")
      .remove("name" => "feedback_reviewed")
      .remove("name" => "feedback_reviewed_at")
      .remove("name" => "graded_at")
      .remove("name" => "graded_by_id")
      .remove("name" => "instructor_modified")
      .remove("name" => "score")
      .remove("name" => "status")
      .remove("name" => "submission_id")
      .remove("name" => "submitted_at")
      .remove("name" => "updated_at")
      .exclude { |changeset|
        changeset["object"] == "Grade" &&
          changeset["event"] == "create" &&
          !changeset.keys.include?("raw_score")
      }
      .changeset
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
