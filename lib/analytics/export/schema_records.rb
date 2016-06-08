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
              # let's get the base-one record number for comparison against the
              # size of the records array
              record_number = index + 1

              # print a message for the record if it fits into our
              # messaging schema
              print progress_message(record_number: record_number) \
                if messageable_record?(record_number: record_number)

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

      # build the progress message to show how far along we are in the export
      def progress_message(record_number:)
        percent_complete = (record_number * 100.0 / total_records).round
        "\r       record #{record_number} of #{total_records} (#{percent_complete}%)"
      end

      # is this a record that we want to be printing a message for during
      # export?
      def messageable_record?(record_number:)
        # we shouldn't be messaging for records beyond those in the size of the
        # records array. this shouldn't happen regardless, but let's return false
        # to ensure that this anomaly doesn't occur.
        return false if record_number > total_records

        # the record should be messageable if it's divisible by five, or if it's
        # the last record in the records array
        record_number % 5 == 0 || record_number == total_records
      end

      # this is being used a lot, so let's cache it since we can cheaply save
      # some cycles
      def total_records
        @total_records ||= records.size
      end
    end
  end
end
