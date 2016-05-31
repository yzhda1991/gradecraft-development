require "showtime"

module Presenters
  module SubmissionFiles
    class Base < Showtime::Presenter

      def submission_file
        return nil unless params[:submission_file_id]
        @submission_file ||= ::SubmissionFile.find params[:submission_file_id]
      end

      def submission
        return nil unless submission_file
        submission_file.submission
      end

      def submission_file_streamable?
        submission_file && submission_file.streamable?
      end

      def write_submission_file_to_tempfile
        submission_file.write_tempfile_from_stream temp_filename: filename
      end

      def filename
        submission_file.instructor_filename params[:index].to_i
      end

      def mark_submission_file_missing
        return false unless submission_file
        submission_file.mark_file_missing
      end

    end
  end
end
