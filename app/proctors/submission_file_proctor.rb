class SubmissionFileProctor
  attr_reader :submission_file, :user, :course

  def initialize(submission_file)
    @submission_file = submission_file
  end

  def downloadable?(user:, course: nil)
    @course = course || submission.course
    @user = user

    proctor_conditions.for(:downloadable).satisfied?
  end

  def proctor_conditions
    @proctor_conditions ||= ProctorConditions::SubmissionFile.new(
      submission_file: submission_file,
      user: user,
      course: course
    )
  end

  def submission
    @submission ||= submission_file.submission
  end
end
