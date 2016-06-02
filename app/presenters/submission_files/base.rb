require "showtime"

module Presenters
  module SubmissionFiles
    class Base < Showtime::Presenter

      attr_accessor :downloaded_files

      def initialize(args={})
        super
        @downloaded_files = []
      end

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
        result = submission_file.fetch_object_to_tempdir temp_filename: filename
        @downloaded_files << result if result
      end

      def tempfiles_exist?
        !tempfile_paths.empty?
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
