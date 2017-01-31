class ErrorsController < ApplicationController
  skip_before_action :require_login
  skip_before_action :require_course_membership

  def show
    render status: params[:status_code].blank? ? 500 : params[:status_code],
      layout: "error", locals: { error_type: params[:error_type] }
  end
end
