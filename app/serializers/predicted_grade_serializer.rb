# Called from the PredictedAssignmentSerializer, this class manages the
# presentation of a student's grade for an Assignment on the Predictor Page.
#
# PERMISSIONS:
#  * Students CAN ONLY see released grades
#  * Faculty CAN NOT view student predictions

class PredictedGradeSerializer
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
    return 0 if show_zero_in_predictor grade.raw_score
    grade.raw_score if grade.is_student_visible?
  end

  def score
    return 0 if show_zero_in_predictor grade.score
    grade.score if grade.is_student_visible?
  end

  def initialize(assignment, grade, current_user)
    @assignment = assignment
    @grade = grade
    @current_user = current_user
  end

  def attributes
    {
      id: id,
      predicted_score: predicted_score,
      score: score,
      raw_score: raw_score,
    }
 end

  private

  def show_zero_in_predictor(score)
    score.nil? &&
    assignment.accepts_submissions? &&
    assignment.submissions_have_closed? &&
    grade.student.submission_for_assignment(grade.assignment).nil?
  end

  attr_reader :assignment, :grade
end

