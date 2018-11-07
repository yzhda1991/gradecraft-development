require "mongoid"

class HomeController < ApplicationController
  skip_before_action :require_login
  skip_before_action :require_course_membership
  before_action :ensure_admin?, only: :health_check

  layout "blank", only: :style_guide

  # root
  # GET /
  def index
    redirect_to dashboard_path and return if logged_in?
  end

  def reset_password
  end

  def style_guide
  end

  def health_check
    begin
      @mongo_status = Mongoid.default_client.command(ping: 1).documents.first == {"ok"=>1.0} ? "Connected" : "Error"
      @redis_status = Resque.redis.redis.call("ping") == "PONG" ? "Connected" : "Error"
    rescue StandardError => e
      @error = e.message
      raise
    end
  end
end
