class HomeController < ApplicationController

  # root
  # GET /
  def index
    redirect_to dashboard_path if logged_in?

    if Rails.env.production?
      render :umich
    else
      render :public
    end
  end

  def login
  end
end
