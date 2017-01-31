class ErrorsController < ApplicationController
  def show
    @error = ApplicationError.new application_error_params
    render status: @error.status_code, layout: "error"
  end

  private

  def application_error_params
    params.permit(:message, :header, :status_code, :redirect_path)
  end
end
