class API::BadgesController < ApplicationController

  # GET api/badges
  def index
    @badges = current_course.badges.select(
      :can_earn_multiple_times,
      :course_id,
      :description,
      :full_points,
      :icon,
      :id,
      :name,
      :position,
      :visible,
      :visible_when_locked)

    if current_user_is_student?
      @student = current_student
      @update_predictions = !student_impersonation?

      if !student_impersonation?
        @badges.includes(:predicted_earned_badges)
        @predicted_earned_badges =
          PredictedEarnedBadge.find_or_create_for_student(
            current_course.id, @student.id
          )
      end
    end
  end
end
