class ChallengeGradeUpdatePerformer < ResqueJob::Performer
  def setup
    @challenge_grade = fetch_grade_with_challenge
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    require_save_scores_success
    require_notify_released_success
  end

  protected

  def require_save_scores_success
    require_success(save_scores_messages) do
      @challenge_grade.cache_team_and_student_scores
    end
  end

  def require_notify_released_success
    if ChallengeGradeProctor.new(@challenge_grade).viewable?
      require_success(notify_released_messages, max_result_size: 200) { notify_challenge_grade_released }
    end
  end

  def save_scores_messages
    {
      success: "Team and student scores saved successfully for challenge grade ##{@challenge_grade.id}",
      failure: "Team and student scores failed to save for challenge grade ##{@challenge_grade.id}"
    }
  end

  def notify_released_messages
    {
      success: "Successfully sent notification of challenge grade release.",
      failure: "Failed to send challenge grade release notification."
    }
  end

  def fetch_challenge_grade_with_challenge
    ChallengeGrade.where(id: @attrs[:challenge_grade_id]).includes(:challenge).load.first
  end

  def notify_grade_released
    #NotificationMailer.challenge_grade_released(@challenge_grade.id).deliver_now
  end
end
