class API::CopyLogsController < ApplicationController
  before_action :ensure_admin?

  # GET /api/courses/:course_id/copy_log
  def show
    course = Course.find(params[:course_id])
    if course.copy_log.present?
      render json: { log: course.copy_log.to_hash }
    else
      render json: { message: "no copy log for this course"}
    end
  end
end
