module Analytics
  module Export

    # This class is used to build a hash of all final values for the records
    # that have been designated for export in the containing
    # Analytics::Export::Mdoel class.
    #
    # The result of #parse_records! will produce a hash of parsed arrays in
    # which each
    #
    # {
    #   username: ["dave_b", "anne_c", "karen_w"],
    #   role: ["admin", "owner", "owner"], ...
    # }
    #
    class RecordParser
      attr_reader :export, :records

      def initialize(export:, records:)
        @export = export
        @records = records
      end

      # construct a hash that builds an empty array for the default value
      def parse_records!
        puts " => Generating schema records..."

        Hash.new {|hash, key| hash[key] = [] }.tap do |parsed_export_data_by_column|
          # iterate over the export mapping format defined in the export class
          # that subclassed Analytics::Export::Model
          #
          export_mapping.each do |column_name, parsing_method|
            # we're inspecting these because it's possible that we might have a
            # Proc or a different class altogether for the parsing_method
            #
            puts "    => column #{column_name.inspect}, parse method #{parsing_method.inspect}"

            parsed_export_data_by_column[column_name] = records.each_with_index.map do |record, index|
              # print messages for our records on output so we can keep track of
              # our progress
              #
              message = Message.new \
                record_index: index,
                total_records: records.size

              print message.formatted_message if message.printable?

              schema_record = ExportRecord.new \
                parsing_method: parsing_method,
                record: record,
                export: export

              schema_record.parsed_value
            end
          end
        end
      end

      # this is the schema for the target Export class
      def export_mapping
        export.class.export_mapping
      end
    end
  end
end
