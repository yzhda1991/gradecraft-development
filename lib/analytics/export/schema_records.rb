module Analytics
  module Export

    # This class is used to build a hash of all schema records for a given
    # export class. The result of #map_records! will follow this format:
    #
    # {
    #   username: ["dave_b", "anne_c", "karen_w"],
    #   role: ["admin", "owner", "owner"], ...
    # }
    #
    class SchemaRecords
      attr_reader :export, :records

      def initialize(export:, records:)
        @export = export
        @records = records
      end

      # construct a hash that builds an empty array for the default value
      def map_records!
        puts " => Generating schema records..."

        Hash.new {|hash, key| hash[key] = [] }.tap do |final_hash|
          # iterate over the schema defined in the Mongo class
          schema.each do |column, row|
            puts "    => column #{column.inspect}, row #{row.inspect}"

            final_hash[column] = records.each_with_index.map do |record, index|
              # print a message for the record if it fits into our
              # messaging schema
              message = Analytics::Export::RecordMessage.new \
                record_index: index,
                total_records: records.size
              print message.formatted_message if message.printable?

              # get the value from the row however we can
              next row.call(record) if row.respond_to? :call # try call first
              next record.send(row) if record.respond_to? row # then try the record
              export.send row, record, index # then perform the method on the export
            end
          end
        end
      end

      # this is the schema for the target Mongo class
      def schema
        export.class.schema
      end
    end
  end
end
