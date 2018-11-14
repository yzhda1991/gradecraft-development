class NotificationMailerPreview < ActionMailer::Preview
  def earned_badge_awarded
    earned_badge = EarnedBadge.last
    NotificationMailer.earned_badge_awarded earned_badge
  end

  def new_submission
    submission = Submission.last
    professor = User.first
    NotificationMailer.new_submission submission.id, professor
  end

  def challenge_grade_released
    challenge_grade = ChallengeGrade.last
    NotificationMailer.challenge_grade_released challenge_grade
  end

  def grade_released
    grade = Grade.last
    NotificationMailer.grade_released grade.id
  end

  def group_notify
    group = Group.first
    @student = group.students.first
    NotificationMailer.group_notify group.id
  end

  def group_status_updated
    group = Group.first
    @student = group.students.first
    NotificationMailer.group_status_updated group.id
  end

  def lti_error
    user = User.first
    course = Course.first
    NotificationMailer.lti_error user, course
  end

  def revised_submission
    submission = Submission.last
    professor = User.first
    NotificationMailer.revised_submission submission.id, professor
  end

  def successful_submission
    submission = Submission.last
    NotificationMailer.successful_submission submission.id
  end

  def updated_submission
    submission = Submission.last
    NotificationMailer.updated_submission submission
  end

  def unlocked_condition
    course = Course.first
    badge = Badge.first
    student = User.first
    NotificationMailer.unlocked_condition(badge, student, course)
  end
end
