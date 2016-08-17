module Analytics
  module Export
    class ProgressMessage
      attr_reader :record_number, :total_records, :print_every

      def initialize(record_index:, total_records:, print_every: 10)
        # the record_number is the base-one position for the record relative to
        # the total number of records, whereas the index is base-zero. This
        # helps us do comparisons against the total number of records without
        # having to constantly make this adjustment
        @record_number = record_index + 1

        # this is the total number of records in the export
        @total_records = total_records

        # by default only records with an index divisible by 10 are printable
        @print_every = print_every
      end

      def printable?
        # this shouldn't be printable if the record number is greater than the
        # size of the records array itself
        return false if record_number > total_records

        # the record should be messageable if it's divisible by five, or if it's
        # the last record in the records array
        record_number % print_every == 0 || record_number == total_records
      end

      def percent_complete
        (record_number * 100.0 / total_records).round
      end

      def to_s
        "record #{record_number} of #{total_records} " \
        "(#{percent_complete}% complete)"
      end
    end
  end
end
