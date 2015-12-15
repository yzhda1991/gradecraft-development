class PredictedGrade
  attr_reader :current_user

  def id
    grade.id
  end

  def pass_fail_status
    grade.pass_fail_status if grade.is_student_visible?
  end

  def predicted_score
    grade.student == current_user ? grade.predicted_score : 0
  end

  def raw_score
    grade.raw_score if grade.is_student_visible?
  end

  def score
    grade.score if grade.is_student_visible?
  end

  def initialize(grade, current_user)
    @grade = grade
    @current_user = current_user
  end

  private

  attr_reader :grade
end
