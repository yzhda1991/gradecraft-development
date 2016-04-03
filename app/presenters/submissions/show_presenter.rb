require_relative "../../models/history_filter"
require_relative "presenter"
require_relative "grade_history"

class Submissions::ShowPresenter < Submissions::Presenter
  include Submissions::GradeHistory

  def id
    properties[:id]
  end

  def individual_assignment?
    assignment.is_individual?
  end

  def owner
    individual_assignment? ? submission.student : submission.group
  end

  def owner_name
    individual_assignment? ? student.first_name : group.name
  end

  def grade
    owner_id_attr = individual_assignment? ? :student_id : :group_id
    @grade ||= assignment.grades.where("#{owner_id_attr}": owner.id).first
  end

  def submission
    @submission ||= Submission.find id
  end

  def submission_grade_history
    submission_grade_filtered_history(submission, grade, false)
  end

  def submitted_at
    submission.submitted_at
  end

  def open_for_editing?
    (assignment.open? && !grade.present?) ||
      (assignment.open? && assignment.resubmissions_allowed?)
  end

  def title
    "#{owner_name}'s #{assignment.name} Submission " \
      "(#{view_context.points assignment.point_total} " \
      "#{"point".pluralize(assignment.point_total)})"
  end
end
