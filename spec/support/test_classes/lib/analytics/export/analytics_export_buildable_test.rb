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
end
