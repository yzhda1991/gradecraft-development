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

    return unless current_user_is_student?
    @student = current_student
    @allow_updates = !student_impersonation?

    return unless !student_impersonation?
    @badges.includes(:predicted_earned_badges)
    @predicted_earned_badges =
      PredictedEarnedBadge.for_course(current_course).for_student(current_student)
  end
end
