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
      CSV.foreach(file, headers: true, encoding: "iso-8859-1:utf-8") { |csv| rows << AssignmentRow.new(csv) }
    end
    rows
  end

  # Takes an array of AssignmentRows and creates assignments for the specified
  # course
  def import(assignment_rows, course)
    assignment_rows.each do |row|
      assignment_type_id = find_or_create_assignment_type row, course
      next if assignment_type_id.nil?

      assignment = Assignment.create do |a|
        a.name = row[:assignment_name]
        a.assignment_type_id = assignment_type_id
        a.description = row[:description]
        a.full_points = row[:point_total]
        a.due_at = row[:selected_due_date]
        a.course = course
      end

      if assignment.persisted?
        successful << {
          name: assignment.name,
          assignment_type_name: assignment.assignment_type.name,
          description: assignment.description,
          full_points: assignment.full_points,
          due_at: assignment.due_at,
        }
      else
        append_unsuccessful row.to_h, "Assignment is invalid"
      end
    end

    self
  end

  private

  def append_unsuccessful(row, error)
    unsuccessful << { data: row.to_s, error: error }
  end

  def find_or_create_assignment_type(row, course)
    if row[:selected_assignment_type].nil?
      assignment_type_id = matching_assignment_type_id course.assignment_types, row[:assignment_type]
      # If assignment type exists but one was not selected, the record is invalid
      if assignment_type_id.present?
        # Automatically resolve type id if the name matches
        assignment_type_id
      else
        type = course.assignment_types.create name: row[:assignment_type]
        if type.persisted?
          type.id
        else
          append_unsuccessful row.to_h, "Assignment type is invalid"
          return nil
        end
      end
    else
      if course.assignment_types.pluck(:id).include? row[:selected_assignment_type]
        row[:selected_assignment_type]
      else
        append_unsuccessful row.to_h, "Invalid assignment type selected"
        return nil
      end
    end
  end

  def matching_assignment_type_id(assignment_types, imported_type)
    parsed_assignment_type_id assignment_types, imported_type
  end

  class AssignmentRow
    include QuoteHelper
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def assignment_name
      remove_smart_quotes(data[0]).strip
    end

    def assignment_type
      remove_smart_quotes(data[1]).strip
    end

    def point_total
      remove_smart_quotes(data[2]).strip
    end

    def description
      remove_smart_quotes(data[3]).strip
    end

    def due_date
      remove_smart_quotes(data[4]).strip
    end
  end
end
