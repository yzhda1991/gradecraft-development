module Analytics
  module Export
    class SchemaRecords
      attr_reader :export, :records, :verbose

      def initialize(export:, records:, verbose: true)
        @export = export
        @records_set = records_set
        @verbose = verbose
      end

      # {
      #   username: ["blah", "blah2", "blah3"],
      #   role: ["admin", "owner", "owner"], ...
      # }
      def build_hash!
        puts " => Generating schema records..." if verbose

        Hash.new { |hash, key| hash[key] = [] }.tap do |h|
          all_elapsed = Benchmark.realtime do

            export.class.schema.each do |column, value|
              elapsed = Benchmark.realtime do
                puts "    => column #{column.inspect}, value #{value.inspect}"

                h[column] = recs.each_with_index.map do |record, i|
                  print "\r       record #{i} of #{total_records} (#{(i*100.0/total_records).round}%)" if i % 5 == 0 || i == (total_records - 1)
                  if value.respond_to? :call
                    value.call(record)
                  elsif record.respond_to? value
                    record.send(value)
                  else
                    export.send(value, record, i)
                  end
                end

              end
              puts "\n       Done. Elapsed time: #{elapsed} seconds"
            end

          end
          puts "     Done. Elapsed time: #{all_elapsed} seconds"
        end
      end

      def total_records
        records.size
      end

    end
  end
end
