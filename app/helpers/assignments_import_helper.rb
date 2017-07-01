module AssignmentsImportHelper
  # Adopted from https://stackoverflow.com/a/22360500
  # Attempts to parse date according to "mm/dd/yyyy hh:mm:ss AM/PM" format and then
  # converts to number of floating point seconds for a Javascript-friendly time
  def date_to_floating_point_seconds(due_date)
    date = parsed_date(due_date)
    return nil if date.nil?
    date.to_f * 1000
  end

  # Attempts to match imported assignment type with one that currently exists
  # in Gradecraft
  # Returns: :id
  def parsed_assignment_type_id(assignment_types, imported_type)
    return nil if imported_type.nil?
    type = assignment_types.find { |k, v| k.name.downcase == imported_type.downcase }
    type.try(:id)
  end

  private

  def parsed_date(date)
    begin
      lowercase_meridian_indicator_date = date.sub(/am/i, "am").sub(/pm/i, "pm")
      Time.strptime(lowercase_meridian_indicator_date, "%m/%d/%Y %I:%M:%S %P")
    rescue ArgumentError
      nil
    end
  end
end
