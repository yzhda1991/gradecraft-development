class Analytics::Export::Message
  attr_reader :record_number, :total_records

  def initialize(record_index:, total_records:)
    # the record_number is the base-one position for the record relative to the
    # total number of records, whereas the index is base-zero. This helps us do
    # comparisons against the total number of records without having to
    # constantly make this adjustment
    @record_number = record_index + 1

    # this is the total number of records in the export
    @total_records = total_records
  end

  # print the progress message to show how far along we are in the export
  def formatted_message
    "\r       #{progress_message}"
  end

  def progress_message
    "record #{record_number} of #{total_records} (#{percent_complete}%)"
  end

  def printable?
    # this shouldn't be printable if the record number is greater than the size
    # of the records array itself
    return false if record_number > total_records

    # the record should be messageable if it's divisible by five, or if it's
    # the last record in the records array
    record_number % 5 == 0 || record_number == total_records
  end

  def percent_complete
    (record_number * 100.0 / total_records).round
  end
end
