class SubmissionsExportPresenter < Presenter::Base
  def export_file_name
    properties.export_file_name
  end

  def csv_file_path
    properties.csv_file_path
  end

  def archive_name #needs specs
    "#{properties.assignment.name}"
  end
end
