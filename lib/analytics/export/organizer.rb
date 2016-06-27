module Analytics
  module Export
    class Organizer
      def builder
        @builder ||= Builder.new organizer: self
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
