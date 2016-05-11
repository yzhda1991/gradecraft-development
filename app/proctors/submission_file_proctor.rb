class SubmissionFileProctor
  attr_reader :submission_file, :user, :course, :group

  def initialize(submission_file)
    @submission_file = submission_file
  end

  def downloadable?(user:, course: nil)
    @course = course || submission.course
    @user = user

    return false unless submission_matches_course?
    return true if user_is_staff?
    return false unless no_assignment_present?

    if assignment.is_individual?
      return user_owns_submission?
    elsif assignment.has_groups?
      return false unless user_has_group_for_assignment?
      return user_group_owns_submission?
    end

    false
  end

  def submission_matches_course?
    submission.course_id == course.id
  end

  def user_is_staff?
    user.is_staff? course
  end

  def no_assignment_present?
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

  def submission
    @submission ||= submission_file.submission
  end

  def assignment
    @assignment ||= submission.assignment
  end
end
