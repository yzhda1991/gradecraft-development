require "application_responder"
require "lull"
require "./app/event_loggers/login_event"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder

  include Omniauth::Lti::Context
  include Croutons::Controller
  include CustomNamedRoutes
  include CurrentScopes
  include CourseTerms
  include ZipUtils

  respond_to :html

  protect_from_forgery with: :null_session

  around_action :time_zone, if: :current_user

  Rails.env.production? do
    before_action :check_url
  end

  def check_url
    redirect_to request.protocol + "www." + request.host_with_port +
      request.fullpath if !/^www/.match(request.host)
  end

  before_action :require_login, except: [:not_authenticated]
  before_action :require_course_membership, except: [:not_authenticated]
  before_action :increment_page_views
  before_action :set_paper_trail_whodunnit

  include ApplicationHelper
  include ImpersonationHelper
  include AuthenticationHelper

  def not_authenticated
    if !request.env["REMOTE_USER"].nil?
      @user = User.find_by_username(request.env["REMOTE_USER"])
      if @user
        auto_login(@user)
        redirect_to dashboard_path
      else
        redirect_to root_url, alert: "Please login first."
        # TODO: We ultimately need to handle Cosign approved users who don't
        # have GradeCraft accounts
      end
    else
      redirect_to root_path, alert: "Please login first."
    end
  end

  def redirect_back_or_default(path=root_path, options={})
    if request.env["HTTP_REFERER"].present? &&
       request.env["HTTP_REFERER"] != request.env["REQUEST_URI"]
      redirect_back(fallback_location: path)
    else
      redirect_to path, options
    end
  end

  # Tracking course logins
  def record_course_login_event(event_options = {})
    return unless request.format.html? || request.format.xml?
    event_attrs = event_session.merge event_options

    EventLoggers::LoginEvent.new.log_later(event_attrs.merge(request: nil))
  end

  # Session data used for building attributes hashes in EventLogger classes
  def event_session
    {
      course: current_course,
      user: current_user,
      student: current_student,
      request: request
    }
  end

  protected

  def use_current_course
    @course = current_course
  end

  def save_referer
    session[:return_to] = request.referer
  end

  # Sorcery activity logging overrides
  def register_last_activity_time_to_db
    return unless Config.register_last_activity_time
    return unless logged_in?
    user = impersonating? ? impersonating_agent : current_user
    user.set_last_activity_at(Time.now.in_time_zone)
  end

  def register_last_ip_address(_user, _credentials)
    return unless Config.register_last_ip_address
    user = impersonating? ? impersonating_agent : current_user
    user.set_last_ip_address(request.remote_ip)
  end

  def register_logout_time_to_db
    return unless Config.register_logout_time
    user = impersonating? ? impersonating_agent : current_user
    user.set_last_logout_at(Time.now.in_time_zone)
  end

  private

  def current_ability
    @current_ability ||= Ability.new(current_user, current_course)
  end

  # Tracking page view counts
  def increment_page_views
    return unless current_user && request.format.html?
    PageviewEventLogger.new(event_session)
                       .enqueue_in_with_fallback Lull.time_until_next_lull
  end

  def time_zone(&block)
    Time.use_zone(current_user.time_zone, &block)
  end
end
