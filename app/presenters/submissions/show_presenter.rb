require_relative "presenter"
require_relative "grade_history"

module Submissions
  class ShowPresenter < Submissions::Presenter
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
      @submission ||= ::Submission.where(id: id).first
    end

    def present_submission_files
      return [] unless submission
      @present_submission_files ||= submission.submission_files.present
    end

    def missing_submission_files
      return [] unless submission
      @missing_submission_files ||= submission.submission_files.missing
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

    def open_for_editing?(student)
      student.present? &&
      assignment.accepts_submissions? &&
      !assignment.submissions_have_closed? &&
      ( assignment.is_unlocked_for_student?(student) ||
        ( assignment.has_groups? &&
          assignment.is_unlocked_for_group?(
            student.group_for_assignment(assignment))
        )
      )
    end

    def title
      "#{owner_name}'s #{assignment.name} Submission " \
        "(#{view_context.points assignment.full_points} " \
        "#{"point".pluralize(assignment.full_points)})"
    end
  end
end
