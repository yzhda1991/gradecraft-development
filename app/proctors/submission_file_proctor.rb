class SubmissionFileProctor
  attr_reader :submission_file

  def initialize(submission_file)
    @submission_file = submission_file
  end

  def downloadable?(user:, course: nil)
    @course = course || submission.course

    # not downloadable if the user doesn't match the course
    return false unless submission.course_id == @course.id

    # downloadable if user is staff for the current course
    return true if user.is_staff? @course

    # not downloadable if there's not assignment for the submission
    return false unless !assignment.nil?

    if assignment.is_individual?
      # downloadable if the user is the student who owns this submission
      return submission.student_id == user.id
    elsif assignment.has_groups?
      # there needs to be a group
      return false unless group = user.group_for_assignment(assignment)

      # downloadable if the user is in the group that owns the submission
      return group.id == submission.group_id
    end

    # otherwise not downloadable
    false
  end

  def submission
    @submission ||= submission_file.submission
  end

  def assignment
    @assignment ||= submission.assignment
  end
end
