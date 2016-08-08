require "analytics/export"

class AnalyticsExportBuildableTest
  include Analytics::Export::Buildable

  def export_data
    {}
  end

  def export_classes
    []
  end

  def filename
    "export.zip"
  end

  def directory_name
    "ECO500"
  end

  def upload_file_to_s3(filepath)
    filepath
  end
end
