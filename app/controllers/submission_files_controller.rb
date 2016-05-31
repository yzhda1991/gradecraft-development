require_relative "../presenters/submission_files/base"

class SubmissionFilesController < ApplicationController
  def download
    authorize! :download, presenter.submission_file

    # let's use the object_stream here because there's no reason to hit S3 twice
    if presenter.submission_file_object_exists?
      send_file presenter.get_renamed_submission_file_object
    else
      presenter.mark_submission_file_missing
      flash[:alert] = "The requested file was not found on the server."
      redirect_to request.referrer
    end
  end

  def presenter
    @presenter ||= Presenters::SubmissionFiles::Base.new params: params
  end
end
