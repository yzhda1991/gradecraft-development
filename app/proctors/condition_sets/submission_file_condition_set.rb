require "proctor"

module Proctors
  class SubmissionFileConditionSet
    include Proctor::ConditionSet

    attr_accessor :group

    # this uses the resources on the proctor rather than defining them here
    defer_to_proctor :submission, :assignment, :course, :submission_file

    def downloadable_conditions
      add_requirements :submission_matches_course?, :assignment_present?
      add_overrides :user_is_staff?
      add_requirement :user_owns_submission? if assignment.is_individual?
      add_group_requirements if assignment.has_groups?
    end

    def add_group_requirements
      add_requirements :user_has_group_for_assignment?,
        :user_group_owns_submission?
    end

    def submission_matches_course?
      submission.course_id == course.id
    end

    def user_is_staff?
      user.is_staff? course
    end

    def assignment_present?
      !assignment.nil?
    end

    def user_owns_submission?
      submission.student_id == user.id
    end

    def user_has_group_for_assignment?
      @group = user.group_for_assignment(assignment)
    end

    def user_group_owns_submission?
      group.id == submission.group_id
    end
  end
end
