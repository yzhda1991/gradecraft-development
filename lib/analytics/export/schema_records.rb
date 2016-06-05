module Analytics
  module Export
    class SchemaRecords
      attr_reader :export, :records

      def initialize(export:, records:)
        @export = export
        @records = records
      end

      # {
      #   username: ["blah", "blah2", "blah3"],
      #   role: ["admin", "owner", "owner"], ...
      # }
      def build_hash!
        puts " => Generating schema records..."

        # construct a hash that builds an empty array for the default value
        Hash.new {|hash, key| hash[key] = [] }.tap do |final_hash|
          export.class.schema.each do |column, row|
            puts "    => column #{column.inspect}, row #{row.inspect}"

            final_hash[column] = records.each_with_index.map do |record, index|
              print progress_message(index: i) if fifth_record?(index: index)

              if row.respond_to? :call
                row.call record
              elsif record.respond_to? row
                record.send row
              else
                export.send row, record, index
              end
            end
          end

        end
      end

      def progress_message(index:)
        percent_complete = (index * 100.0 / total_records).round
        "\r       record #{index} of #{total_records} (#{percent_complete}%)"
      end

      def fifth_record?(index:)
        index % 5 == 0 || index == (total_records - 1)
      end

      def total_records
        @total_records ||= records.size
      end
    end
  end
end
