class CurrentCoursesController < ApplicationController
  skip_before_filter :verify_authenticity_token
  respond_to :json

  # Switch between enrolled courses
  def change
    if course = current_user.courses.where(:id => params[:course_id]).first
      unless session[:course_id] == course.id
        session[:course_id] = course.id
        log_course_login_event
      end
    end
    redirect_to root_url
  end
end
