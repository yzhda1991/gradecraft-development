module Analytics
  module Export
    class CSV
      attr_reader :export, :path, :filename, :schema_record_set

      def initialize(export:, path:, filename: nil, schema_record_set: nil)
        @export = export
        @path = path
        @filename = filename
        @schema_record_set = schema_record_set
      end
    end

    schema_recs = schema_record_set || export.schema_records
    unless File.exists?(path) && File.directory?(path)
      FileUtils.mkdir_p(path)
    end
    file_name ||= "#{export.class.name.underscore}.csv"

    CSV.open(File.join(path, file_name), "wb") do |csv|
      # Write header row
      csv << export.class.schema.keys

      # Zip schema_records values from each key
      schema_recs.values.transpose.each{ |record| csv << record }
    end

    end
  end
end
