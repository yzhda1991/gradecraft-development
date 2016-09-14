module PredictorData
  extend ActiveSupport::Concern

  def predictor_challenges(student)
    return [] unless challenge_conditions_met? student

    current_course.challenges.select(
      :id,
      :name,
      :visible,
      :description,
      :full_points,
      :due_at
    ).map do |challenge|
      prediction =
        challenge.find_or_create_predicted_earned_challenge(@student.id)
      if current_user_is_student? && !student_impersonation?
        challenge.prediction = {
          id: prediction.id, predicted_points: prediction.predicted_points
        }
      else
        challenge.prediction = {
          id: prediction.id, predicted_points: 0
        }
      end

      challenge.grade = predicted_grade_for_challenge(student, challenge)
      challenge
    end
  end

  def predictor_assignment_types
    current_course.assignment_types.ordered
      .select(
        :course_id,
        :id,
        :name,
        :max_points,
        :description,
        :student_weightable,
        :position,
        :updated_at
      )
  end

  private

  def challenge_conditions_met?(student)
    current_course.challenges.present? &&
    student.team_for_course(current_course).present? &&
    current_course.add_team_score_to_student
  end

  def predicted_grade_for_challenge(student, challenge)
    team = student.team_for_course(current_course)
    grade = team.challenge_grades.where(challenge_id: challenge.id).first
    if grade.present? && ChallengeGradeProctor.new(grade).viewable?
      challenge_grade = {
        score: grade.score,
        # The Predictor js calculates points off of Assignment final_points,
        # We can use the same templates for Challenges if we treat
        # the score as the Challenge final_points
        final_points: grade.score
      }
    else
      challenge_grade = {
        score: nil,
        final_points: nil
      }
    end
    challenge_grade
  end
end
