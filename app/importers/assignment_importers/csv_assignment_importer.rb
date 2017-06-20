require "csv"

class CSVAssignmentImporter
  include AssignmentsImportHelper
  attr_reader :successful, :unsuccessful

  def initialize
    @successful = []
    @unsuccessful = []
  end

  # Parses and converts each row in the file to an AssignmentRow
  def as_assignment_rows(file)
    rows = []
    if !file.blank?
      CSV.foreach(file, headers: true) { |csv| rows << AssignmentRow.new(csv) }
    end
    rows
  end

  # Takes an array of AssignmentRows and creates assignments for the specified
  # course
  def import(assignment_rows, course)
    assignment_rows.each do |row|
      assignment_type_id = find_or_create_assignment_type row, course

      if assignment_type_id.nil?
        append_unsuccessful row, "Failed to create assignment type"
        next
      end

      assignment = Assignment.create! do |a|
        a.name = row[:assignment_name]
        a.assignment_type_id = assignment_type_id
        a.description = row[:description]
        a.full_points = row[:point_total]
        a.due_at = row[:due_date]
        a.course = course
      end

      if assignment.persisted?
        successful << assignment
      else
        append_unsuccessful row, "Failed to create assignment"
      end
    end

    self
  end

  private

  def append_unsuccessful(row, errors)
    unsuccessful << { data: row.to_s, errors: errors }
  end

  def find_or_create_assignment_type(row, course)
    if row[:selected_assignment_type].nil?
      # If assignment type exists but one was not selected, the record is invalid
      if assignment_type_exists? course.assignment_types, row[:assignment_type]
        return nil
      else
        type = course.assignment_types.create name: row[:assignment_type]
        type.persisted? ? type.id : nil
      end
    else
      if course.assignment_types.pluck(:id).include? row[:selected_assignment_type]
        row[:selected_assignment_type]
      else
        return nil
      end
    end
  end

  def assignment_type_exists?(assignment_types, imported_type)
    !parsed_assignment_type_id(assignment_types, imported_type).nil?
  end

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

    def to_s
      data.to_s
    end
  end
end
