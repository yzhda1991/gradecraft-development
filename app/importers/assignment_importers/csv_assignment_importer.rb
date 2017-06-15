require "csv"

class CSVAssignmentImporter
  attr_reader :successful, :unsuccessful, :unchanged
  attr_accessor :file

  def initialize(file)
    @file = file
    @successful = []
    @unsuccessful = []
    @unchanged = []
  end

  def as_assignment_rows
    rows = []
    convert_to_assignment_rows(file) { |row| rows << row } unless file.blank?
    rows
  end

  def import(course=nil, assignment=nil)
    if !file.blank?
      # TODO: do stuff
    end

    self
  end

  private

  def convert_to_assignment_rows(file, &block)
    CSV.foreach(file, headers: true) do |csv|
      yield AssignmentRow.new csv
    end
  end

  def append_unsuccessful(row, errors)
    unsuccessful << { data: row.to_s, errors: errors }
  end

  # def report(row, grade)
  #   if grade.valid?
  #     successful << grade
  #   else
  #     append_unsuccessful row, grade.errors.full_messages.join(", ")
  #   end
  # end

  class AssignmentRow
    include QuoteHelper
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def assignment_name
      remove_smart_quotes data[0]
    end

    def assignment_type
      remove_smart_quotes data[1]
    end

    def point_total
      remove_smart_quotes data[2]
    end

    def description
      remove_smart_quotes data[3]
    end

    def due_date
      remove_smart_quotes data[4]
    end

    # def to_s
    #   data.to_s
    # end
  end
end
