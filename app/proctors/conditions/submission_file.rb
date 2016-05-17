module Proctors
  module Conditions
    class SubmissionFile
      include Proctor::Conditions

      # this uses the resources on the proctor rather than defining them here
      defer_to_proctor :submission, :assignment, :user, :submission_file

      def downloadable_conditions
        add_requirements :submission_matches_course?, :assignment_present?
        add_overrides :user_is_staff?
        add_requirement :user_owns_submission? if assignment.is_individual?
        add_requirements(:user_has_group_for_assignment?,
          :user_group_owns_submission?) if assignment.has_groups?
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
end
