class PagesController < ApplicationController
  skip_before_action :require_login
  skip_before_action :require_course_membership

  layout "blank", only: :style_guide

  def home
    redirect_to dashboard_path if current_user
  end

  def style_guide
  end
end
