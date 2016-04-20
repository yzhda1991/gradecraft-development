class SubmissionFilesController < ApplicationController
  before_filter :ensure_staff?, only: [:download]

  def download
    presenter = SubmissionFilesPresenter.new({ params: params })
    submission_file = presenter.submission_file
    authorize! :read, submission_file.submission

    # let's use the object_stream here because there's no reason to hit S3 twice
    if submission_file.object_stream.exists?
      send_data submission_file.object_stream.stream!,
        filename: submission_file.instructor_filename(params[:index].to_i)
    else
      submission_file.mark_file_missing
      flash[:alert] = "The requested file was not found on the server."
      redirect_to request.referrer
    end
  end
end
