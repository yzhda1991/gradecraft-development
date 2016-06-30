class CourseAnalyticsExportsController < ApplicationController
  before_filter :ensure_staff?, except: :secure_download

  skip_before_filter :require_login, only: :secure_download
  skip_before_filter :increment_page_views, only: :secure_download
  skip_before_filter :course_scores, only: :secure_download

  authenticate_secure_downloads :course_analytics_export

  def create
    if presenter.create_and_enqueue_export
      flash[:success] = "Your course analytics export is being prepared. " \
                        "You'll receive an email when it's complete."
    else
      flash[:alert] = "Your submissions export failed to build. " \
                      "An administrator has been contacted about the issue."
    end

    redirect_to assignment_path(assignment)
  end

  def destroy
    if presenter.destroy_export
      flash[:success] = "Assignment export successfully deleted from server"
    else
      flash[:alert] = "Unable to delete the submissions export from the server"
    end

    redirect_to exports_path
  end

  def download
    send_data presenter.stream_export, filename: presenter.export_filename
  end

  def secure_download
    if secure_download_authenticator.authenticates?
      send_data presenter.stream_export, filename: presenter.export_filename
    else
      if secure_download_authenticator.valid_token_expired?
        flash[:alert] = "The email link you used has expired."
      else
        flash[:alert] = "The link you attempted to access does not exist."
      end
      flash[:alert] += " Please login to download the desired file."

      redirect_to root_url
    end
  end

  protected

  def secure_download_authenticator
    # it's possible that this could be cleaned up by simply passing params into
    # the authenticator, but the target_id on the SecureToken doesn't match the
    # id being passed in conventionally via the member route for
    # SubmissionsExports#secure_download. This might be worth looking into in
    # future refactoring but it seems like a fine pattern for now since we're
    # only passing request parameters into the authenticator.

    @secure_download_authenticator ||= SecureTokenAuthenticator.new(
      secure_token_uuid: params[:secure_token_uuid],
      secret_key: params[:secret_key],
      target_id: params[:id],
      target_class: "CourseAnalyticsExport"
    )
  end
end
