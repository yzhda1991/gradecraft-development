module AssignmentsImportHelper
  DATETIME_FORMAT = "%m/%d/%Y %I:%M:%S %P".freeze

  # Adopted from https://stackoverflow.com/a/22360500
  # Converts to number of floating point seconds for a Javascript-friendly time
  def date_to_floating_point_seconds(date)
    return nil if date.nil?
    date.to_f * 1000
  end

  # Takes a date, e.g. 1/1/2018, and parses it into a datetime with a default
  #   time of 11:59pm, e.g. 1/1/2018 11:50PM, which is common for something like
  #   a due date
  def parse_date_to_datetime(date, zone=Time.zone, time="11:59:59 pm")
    return nil if date.blank?
    Time.strptime("#{date} #{time}", DATETIME_FORMAT).in_time_zone(zone) rescue nil
  end

  # Attempts to match imported assignment type with one that currently exists
  #   in Gradecraft
  # Returns: :id
  def parsed_assignment_type_id(assignment_types, imported_type)
    return nil if imported_type.nil?
    type = assignment_types.find { |k, v| k.name.downcase == imported_type.downcase }
    type.try(:id)
  end
end
