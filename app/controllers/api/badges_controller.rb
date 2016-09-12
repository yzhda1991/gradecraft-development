class API::BadgesController < ApplicationController
  include PredictorData

  # GET api/badges
  def index
    if current_user_is_student?
      @student = current_student
      @update_predictions = !student_impersonation?
      @badges = predictor_badges(@student)
    else
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
    end
  end
end
