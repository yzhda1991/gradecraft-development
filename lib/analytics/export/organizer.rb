module Analytics
  module Export
    class Organizer
      def builder
        @builder ||= Builder.new \
          export_data: context.export_data,
          export_classes: export_classes,
          filename: filename,
          directory_name: directory_name
      end

      def generate!
        builder.generate!
      end

      def clean_up
        builder.remove_tmpdirs
      end

      def export_filepath
        builder.export_filepath
      end
    end
  end
end
