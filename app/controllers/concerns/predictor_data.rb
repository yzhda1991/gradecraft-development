module PredictorData
  extend ActiveSupport::Concern

  private

  def predictor_badges(student)
    current_course.badges.select(
      :id,
      :name,
      :description,
      :point_total,
      :visible,
      :visible_when_locked,
      :can_earn_multiple_times,
      :position,
      :updated_at,
      :icon
    ).map do |badge|
      prediction = badge.find_or_create_predicted_earned_badge(student.id)
      if current_user.is_student?(current_course)
        badge.prediction = {
          id: prediction.id,
          times_earned: prediction.times_earned_including_actual
        }
        badge
      else
        badge.prediction = {
          id: prediction.id,
          times_earned: prediction.actual_times_earned
        }
        badge
      end
    end
  end

  def predictor_challenges(student)
    challenges = []
    if current_course.challenges.present? &&
        student.team_for_course(current_course).present? &&
        current_course.add_team_score_to_student
      challenges = current_course.challenges.select(
        :id,
        :name,
        :visible,
        :description,
        :point_total)

      team = student.team_for_course(current_course)
      grades = team.challenge_grades

      challenges.each do |challenge|
        prediction =
          challenge.find_or_create_predicted_earned_challenge(@student.id)
        if current_user.is_student?(current_course)
          challenge.prediction = {
            id: prediction.id, points_earned: prediction.points_earned
          }
        else
          challenge.prediction = {
            id: prediction.id, points_earned: 0
          }
        end

        grade = grades.where(challenge_id: challenge.id).first

        if grade.present? && grade.is_student_visible?
          # point_total is presented on the grade model to mirror the
          # assignment.grade.point_total, which is necessary since
          # assignment.grade.point_total is student specific
          #
          # TODO change score to points_earned on the model,
          #      use points_earned in the front end on challenges and grades
          challenge.grade = {
            point_total: challenge.point_total,
            score: grade.score,
            points_earned: grade.score
          }
        else
          challenge.grade = {
            point_total: challenge.point_total,
            score: nil,
            points_earned: nil
          }
        end
      end
    end
    return challenges
  end
end
