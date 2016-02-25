class API::BadgesController < ApplicationController

  # GET api/assignments/:assignment_id/badges
  def index
    @badges = current_course.badges.select(
      :id,
      :name,
      :description,
      :point_total,
      :visible,
      :visible_when_locked,
      :can_earn_multiple_times,
      :position,
      :icon)
  end
end
