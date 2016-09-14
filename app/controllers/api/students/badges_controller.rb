class API::Students::BadgesController < ApplicationController

  before_filter :ensure_staff?

  # GET api/students/:student_id/badges
  def index
    @student = User.find(params[:student_id])
    @update_predictions = false
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
    #@earned_badges = TODO add here and to jbuilder "relationships"
    render template: "api/badges/index"
  end
end
