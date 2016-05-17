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
    @proctor_conditions ||= Proctors::Conditions::SubmissionFile.new(proctor: self)
  end

  def submission
    @submission ||= submission_file.submission
  end

  def assignment
    @assignment ||= submission.assignment
  end
end
