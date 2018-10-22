class HomeController < ApplicationController
  skip_before_action :require_login
  skip_before_action :require_course_membership

  # root
  # GET /
  def index
    redirect_to dashboard_path and return if logged_in?
  end

  def login
  end
end
