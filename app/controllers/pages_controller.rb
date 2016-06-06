class PagesController < ApplicationController
  skip_before_filter :require_login

  def home
    redirect_to dashboard_path if current_user
  end
end
