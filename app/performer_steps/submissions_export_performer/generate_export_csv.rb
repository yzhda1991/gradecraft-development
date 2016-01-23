class SubmissionsExportPerformer::GenerateExportCSV < ResqueJob::Step
  def run
    @export_csv_successful ||= File.exist?(csv_file_path)
  end
end

  require_success(csv_export_messages) do
    @submissions_export.update_attributes export_csv_successful: true
    export_csv_successful?
  end
