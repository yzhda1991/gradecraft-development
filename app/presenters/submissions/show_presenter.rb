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
    individual_assignment? ? student : group
  end

  def owner_name
    return nil unless owner
    individual_assignment? ? student.first_name : group.name
  end

  def grade
    return nil unless owner
    owner_id_attr = individual_assignment? ? :student_id : :group_id
    @grade ||= assignment.grades.find_by "#{owner_id_attr}": owner.id
  end

  def submission
    return nil unless id
    @submission ||= ::Submission.find id
  end

  def student
    submission.student
  end

  def submission_grade_history
    submission_grade_filtered_history submission, grade, false
  end

  def submitted_at
    submission.submitted_at
  end

  def open_for_editing?
    assignment.open? &&
      (!grade.present? || assignment.resubmissions_allowed?)
  end

  def title
    "#{owner_name}'s #{assignment.name} Submission " \
      "(#{view_context.points assignment.point_total} " \
      "#{"point".pluralize(assignment.point_total)})"
  end
end
