class SubmissionFileProctor
  attr_reader :submission_file, :user, :course

  def initialize(submission_file)
    @submission_file = submission_file
  end

  def downloadable?(user:, course: nil)
    @course = course || submission.course
    @user = user

    conditions.downloadable?.satisfied?
  end

  def conditions
    @conditions ||= SubmissionFileConditions.new(
      submission_file: submission_file,
      user: user,
      course: course
    )
  end

  def submission
    @submission ||= submission_file.submission
  end
end
