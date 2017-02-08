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
      @grade ||= assignment.grades.instructor_modified.find_by "#{owner_id_attr}": owner.id
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

    def open_for_editing?
      assignment.open? && resubmissions_allowed?
    end

    def term_for_edit(current_user)
      if !current_user.is_staff?(assignment.course) && submission.text_comment_draft.present?
        "Edit Draft"
      else
        "Edit Submission"
      end
    end

    private

    # If graded, the grade must be released and the assignment must allow resubmissions
    # otherwise, the assignment must allow resubmissions
    def resubmissions_allowed?
      if grade.present?
        grade.graded_and_visible_by_student? && assignment.resubmissions_allowed?
      else
        assignment.resubmissions_allowed?
      end
    end
  end
end
