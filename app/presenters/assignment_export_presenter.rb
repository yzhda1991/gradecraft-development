class AssignmentExportPresenter < Presenter::Base

  # TODO: specs
  def fileized_assignment_name
    properties.assignment.assignment_name
      .downcase
      .gsub(/[^\w\s_-]+/, '') # strip out characters besides letters and digits
      .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2') # remove extra spaces
      .gsub(/\s+/, '_') # replace spaces with underscores
  end

  def export_file_name
    properties.export_file_name
  end

  def csv_file_path
    properties.csv_file_path
  end

  def sorted_student_directory_keys
    submissions_grouped_by_student.keys.sort
  end

  def archive_name #needs specs
    "#{properties.assignment.name}"
  end
end
