class SubmissionProctor
  def initialize(submission)
    @submission = submission
  end

  # If the user is not considered staff, the submission should be viewable
  # Otherwise, it should only be visible if it is not a draft
  def viewable?(user)
    return true if user.is_student?(@submission.course)
    !@submission.draft?
  end

  def viewable_submission(user)
    return nil unless viewable?(user)
    @submission
  end
end
