class ErrorsController < ApplicationController
  skip_before_action :require_course_membership

  def show
    presenter = Errors::ShowPresenter.new error_params
    render status: params[:status_code].blank? ? 500 : params[:status_code],
      layout: "error", locals: { presenter: presenter }
  end

  private

  def error_params
    params.permit(:message, :header, :redirect_path)
  end
end
