class ChallengeGradeReleasedPreview
  def challenge_grade_released
    challenge_grade = ChallengeGrade.last
    NotificationMailer.challenge_grade_released challenge_grade
  end
end
