require "showtime"

module Presenters
  module CourseAnalyticsExports
    class Base < Showtime::Presenter
      # let's know what to call our export so we don't have to do it over
      # and over in the controller or elsewhere
      def resource_name
        "course analytics export"
      end

      def create_and_enqueue_export
        create_export && export_job.enqueue
      end

      # create the export and cache it to @export so when we're looking for it
      # later we don't create a new one
      def create_export
        @export = ::CourseAnalyticsExport.create \
          course_id: current_course.id,
          professor_id: current_user.id
      end

      def export_job
        @export_job ||= ::CourseAnalyticsExportJob.new export_id: export.id
      end

      def export
        @export ||= ::CourseAnalyticsExport.find params[:id]
      end

      # destroying an export should probably automatically delete it from s3
      # as well. let's modify that behavior in a future PR.
      def destroy_export
        export.destroy
      end

      def current_course
        properties.current_course
      end

      def current_user
        properties.current_user
      end

      def stream_export
        export.stream_s3_object_body
      end

      def export_filename
        export.export_filename
      end

      def secure_download_authenticates?
        authenticator.authenticates?
      end

      def secure_download_expired?
        authenticator.valid_token_expired?
      end

      def send_data_options
        [stream_export, filename: export_filename]
      end

      private

      def authenticator
        @authenticator ||= ::SecureTokenAuthenticator.new(
          secure_token_uuid: params[:secure_token_uuid],
          secret_key: params[:secret_key],
          target_id: params[:id],
          target_class: "CourseAnalyticsExport"
        )
      end
    end
  end
end
