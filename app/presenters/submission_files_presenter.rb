class SubmissionFilesPresenter < Showtime::Presenter
  def submission_file
    return nil unless id
    @submission_file ||= ::SubmissionFile.find params[:id]
  end
end
