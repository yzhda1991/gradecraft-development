require "mongoid"

class PagesController < ApplicationController
  skip_before_action :require_login, only: :home
  skip_before_action :require_course_membership
  before_action :ensure_admin?, only: :health_check

  layout "blank", only: :style_guide

  def home
    redirect_to dashboard_path if current_user
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
