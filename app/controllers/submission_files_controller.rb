class SubmissionFilesController < ApplicationController
  def download
    authorize! :download, presenter.submission_file

    # let's use the object_stream here because there's no reason to hit S3 twice
    if presenter.submission_file_streamable?
      tmp_dir = Dir.mktmpdir
      filepath = [tmp_dir, presenter.filename].join "/"
      streamed_file = File.new(filepath, "w") {|f| f << presenter.stream_submission_file }
      send_file streamed_file

      # send_data(presenter.stream_submission_file, filename: presenter.filename)
    else
      presenter.mark_submission_file_missing
      flash[:alert] = "The requested file was not found on the server."
      redirect_to request.referrer
    end
  end

  def presenter
    @presenter ||= SubmissionFilesPresenter.new params: params
  end
end
