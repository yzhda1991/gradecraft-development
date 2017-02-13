class SubmissionProctor
  def initialize(submission)
    @submission = submission
  end

  # If the user is not considered staff, the submission should be viewable
  # Otherwise, it should only be visible if it is not a draft
  def viewable?(user)
    return @submission.belongs_to? user if user.is_student? @submission.course
    !@submission.unsubmitted?
  end

  def viewable_submission(user)
    return nil unless viewable? user
    @submission
  end

  def open_for_editing?(assignment)
    return false if @submission.graded? && !@submission.submission_grade.is_released?
    if @submission.will_be_resubmitted?
      assignment.open? && assignment.resubmissions_allowed?
    else
      assignment.open?
    end
  end
end
