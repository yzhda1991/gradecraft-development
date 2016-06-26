module Analytics
  module Export
    module ClassMethods
      attr_accessor :export_mapping

      # this will be defined in the format of { column_name: :export_method }.
      # export_method in this case could be either a method on the record that
      # we're exporting, or a method on the export class itself that's being
      # tasked with filtering the data that's coming out of the export.
      #
      def export_mapping(mapping)
        @export_mapping = mapping
      end
    end
  end
end
