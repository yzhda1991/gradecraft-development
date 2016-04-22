module SubmissionFileAbility
  def define_submission_file_abilities(user, course)
    can :manage, SubmissionFile do |submission_file|
      submission = submission_file.submission
      assignment = submission.assignment

      # not manageable if the user doesn't match the course
      next false unless submission.course_id == course.id

      # manageable if user is staff for the current course
      next true if user.is_staff?(course)

      # not manageable if there's not assignment for the submission
      next false unless !assignment.nil?

      if assignment.is_individual?
        # manageable if the user is the student who owns this submission
        next submission.student_id == user.id
      elsif assignment.has_groups?
        group = user.group_for_assignment assignment
        # manageable if the user is in the group that owns the submission
        next (group && group.id == submission.group_id)
      end

      # otherwise not manageable
      false
    end
  end
end
