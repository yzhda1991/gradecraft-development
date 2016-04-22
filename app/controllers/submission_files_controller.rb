class SubmissionFilesController < ApplicationController
  before_filter :ensure_staff?, only: [:download]

  def download
    presenter = SubmissionFilesPresenter.new params: params
    authorize! :read, presenter.submission

    # let's use the object_stream here because there's no reason to hit S3 twice
    if presenter.submission_file_streamable?
      send_data presenter.stream_submission_file, filename: presenter.filename
    else
      presenter.mark_submission_file_missing
      flash[:alert] = "The requested file was not found on the server."
      redirect_to request.referrer
    end
  end
end
