require "showtime"

class SubmissionFilesPresenter < Showtime::Presenter
  def submission_file
    return nil unless params[:id]
    @submission_file ||= ::SubmissionFile.find params[:id]
  end

  def submission
    return nil unless submission_file
    submission_file.submission
  end

  def object_streamable?
    return false unless submission_file
    submission_file.object_stream.exists?
  end

  def stream_object
    return nil unless submission_file
    submission_file.object_stream.stream!
  end

  def filename
    submission_file.instructor_filename params[:index].to_i
  end

  def mark_submission_file_missing
    return false unless submission_file
    submission_file.mark_file_missing
  end
end
