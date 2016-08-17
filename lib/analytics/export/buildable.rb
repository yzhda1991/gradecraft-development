module Analytics
  module Export
    module Buildable
      def build_archive!
        export_builder.build_archive!
      end

      def export_builder
        @export_builder ||= Analytics::Export::Builder.new \
          export_context: context,
          export_classes: export_classes,
          filename: filename,
          directory_name: directory_name
      end

      def upload_builder_archive_to_s3
        upload_file_to_s3 export_builder.final_export_filepath
      end
    end
  end
end
