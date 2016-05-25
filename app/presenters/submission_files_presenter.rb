require "showtime"

class SubmissionFilesPresenter < Showtime::Presenter
  def submission_file
    return nil unless params[:submission_file_id]
    @submission_file ||= ::SubmissionFile.find params[:submission_file_id]
  end

  def submission
    return nil unless submission_file
    submission_file.submission
  end

  def submission_file_streamable?
    return false unless submission_file
    submission_file.object_stream.exists?
  end

  def stream_submission_file
    return false unless submission_file_streamable?
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
