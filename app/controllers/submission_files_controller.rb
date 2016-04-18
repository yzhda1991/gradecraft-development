class SubmissionFilesController < ApplicationController
  before_filter :ensure_staff?, only: [:download]

  def download
    presenter = SubmissionFilesPresenter.new({ params: params })
    submission_file = presenter.submission_file
    authorize! :read, submission_file

    send_data submission_file.stream_s3_object,
      filename: submission_file.instructor_filename
  end
end
