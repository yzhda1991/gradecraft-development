require "showtime"

module Presenters
  module CourseAnalyticsExports
    class Base < Showtime::Presenter
      def resource_name
        "course analytics export"
      end

      def create_and_enqueue_export
        create_export && export_job.enqueue
      end

      def create_export
        @export = ::CourseAnalyticsExport.create \
          course_id: current_course.id,
          professor_id: current_user.id
      end

      def export_job
        @export_job ||= ::CourseAnalyticsExportJob.new \
          course_analytics_export_id: @export.id
      end

      def export
        @export ||= ::CourseAnalyticsExport.find params[:id]
      end

      def destroy_export
        return export.destroy if export.delete_object_from_s3
        false
      end

      def course
        @course ||= current_course
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
