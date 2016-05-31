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

      def submission_file_object_exists?
        submission_file && submission_file.exists_on_s3?
      end

      def get_renamed_submission_file_object
        submission_file.fetch_object_to_tempdir temp_filename: filename
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
