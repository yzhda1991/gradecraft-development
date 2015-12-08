class PredictedGrade
  def id
    grade.id
  end

  def pass_fail_status
    grade.pass_fail_status if grade.is_student_visible?
  end

  def predicted_score
    grade.predicted_score if grade.student.is_student?(grade.course)
  end

  def raw_score
    grade.raw_score if grade.is_student_visible?
  end

  def score
    grade.score if grade.is_student_visible?
  end

  def initialize(grade)
    @grade = grade
  end

  private

  attr_reader :grade
end
