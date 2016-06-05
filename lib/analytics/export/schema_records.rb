module Analytics
  module Export
    class SchemaRecords
      attr_reader :export, :records, :verbose

      def initialize(export:, records:, verbose: true)
        @export = export
        @records = records
        @verbose = verbose
      end

      # {
      #   username: ["blah", "blah2", "blah3"],
      #   role: ["admin", "owner", "owner"], ...
      # }
      def build_hash!
        puts " => Generating schema records..." if verbose

        Hash.new { |hash, key| hash[key] = [] }.tap do |h|
          export.class.schema.each do |column, value|
            puts "    => column #{column.inspect}, value #{value.inspect}" if verbose

            h[column] = records.each_with_index.map do |record, i|
              print record_progress_message(index: i) if every_fifth_record?(i)

              if value.respond_to? :call
                value.call(record)
              elsif record.respond_to? value
                record.send(value)
              else
                export.send(value, record, i)
              end
            end
          end

        end
      end

      def record_progress_message(index:)
        "\r       record #{i} of #{total_records} " \
          "(#{(i*100.0/total_records).round}%)"
      end

      def every_fifth_record?(index:)
        i % 5 == 0 || i == (total_records - 1)
      end

      def total_records
        records.size
      end

    end
  end
end
