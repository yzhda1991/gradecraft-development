class SubmissionProctor
  def initialize(submission)
    @submission = submission
  end

  # Viewable if the submission is not an autosaved draft
  def viewable?
    @submission.link.present? || @submission.text_comment.present? ||
      !@submission.submission_files.empty?
  end

  def viewable_submission
    return nil unless viewable?
    @submission
  end
end
