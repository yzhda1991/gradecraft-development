require "csv"

module Analytics
  module Export
    class CSV
      attr_reader :export, :path, :filename, :parsed_schema_records

      def initialize(export:, path:, filename: nil, schema_record_set: nil)
        @export = export
        @path = path
        @filename = filename || "#{export.class.name.underscore}.csv"
        @parsed_schema_records = schema_record_set || export.parsed_schema_records
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

      # generate a 'header' row for the CSV file by pulling the column names
      # from the schema that we defined with set_schema
      def export_column_names
        export.class.schema.keys
      end

      # if each item is the parsed_schema_records array is an ordered array of
      # attributes for the event records that we queried, calling #transpose on
      # the parsed_schema_records array will give us one array for each
      # individual event record that we queried.
      #
      # The reason that we don't just pass in the event itself as an array is
      # that the records that include Analytics::Export::Model records (such as
      # in /app/analytics_exports) define a set of behaviors for how to filter
      # and interpret this data so that the output is more functional for the
      # end-user.
      #
      def export_rows
        parsed_schema_records.values.transpose
      end

      def csv_filepath
        File.join path, filename
      end
    end
  end
end
