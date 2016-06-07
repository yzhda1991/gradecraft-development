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
        CSV.open(csv_filepath, "wb") do |csv|
          # Write header row
          csv << export.class.schema.keys

          # Zip schema_records values from each key
          schema_records.values.transpose.each {|record| csv << record }
        end
      end

      def csv_filepath
        File.join path, filename
      end
    end
  end
end
