class CourseAnalyticsExportsController < ApplicationController
  before_filter :ensure_staff?, except: :secure_download

  skip_before_filter :require_login, only: :secure_download
  skip_before_filter :increment_page_views, only: :secure_download
  skip_before_filter :course_scores, only: :secure_download

  def create
    if presenter.create_and_enqueue_export
      flash[:success] = "Your #{presenter.resource_name} is being prepared. " \
                        "You'll receive an email when it's complete."
    else
      flash[:alert] = "Your #{presenter.resource_name} failed to build. " \
                      "An administrator has been contacted about the issue."
    end

    redirect_to analytics_students_path
  end

  def destroy
    if presenter.destroy_export
      flash[:success] = "#{presenter.resource_name.capitalize} successfully deleted from server"
    else
      flash[:alert] = "Unable to delete the #{presenter.resource_name} from the server"
    end

    redirect_to exports_path
  end

  def download
    send_data(*presenter.send_data_options) and return
  end

  def secure_download
    if presenter.secure_download_authenticates?
      send_data(*presenter.send_data_options) and return
    else
      if presenter.token_expired?
        flash[:alert] = "The email link you used has expired."
      else
        flash[:alert] = "The link you attempted to access does not exist."
      end
      flash[:alert] += " Please login to download the desired file."

      redirect_to root_url
    end
  end

  private

  def presenter
    @presenter ||= Presenters::CourseAnalyticsExports::Base.new params: params
  end
end
