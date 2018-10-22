class PagesController < ApplicationController
  skip_before_action :require_login
  skip_before_action :require_course_membership
  before_action :ensure_admin?, only: :health_check

  layout "blank", only: :style_guide

  def home
    redirect_to dashboard_path if current_user
  end

  def style_guide
  end

  def health_check
  end
end
