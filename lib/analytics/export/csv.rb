require "csv"

module Analytics
  module Export
    class CSV
      attr_reader :export, :path, :filename, :schema_records

      def initialize(export:, path:, filename: nil, schema_record_set: nil)
        @export = export
        @path = path
        @filename = filename || "#{export.class.name.underscore}.csv"
        @schema_records = schema_record_set || export.schema_records

        FileUtils.mkdir_p(path) unless Dir.exists?(path)
      end

      def generate!
        # we're not calling this class, we're calling the standard ruby CSV
        # library from the global namespace, so use ::
        #
        ::CSV.open(csv_filepath, "wb") do |csv|
          # Write header row
          csv << export_column_names

          # Zip schema_records values from each key
          export_rows.each {|record| csv << record }
        end
      end

      def export_column_names
        export.class.schema.keys
      end

      def export_rows
        schema_records.values.transpose
      end

      def csv_filepath
        File.join path, filename
      end
    end
  end
end
