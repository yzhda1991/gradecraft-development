require "showtime"

class SubmissionFilesPresenter < Showtime::Presenter
  def submission_file
    return nil unless params[:id]
    @submission_file ||= ::SubmissionFile.find params[:id]
  end
end
