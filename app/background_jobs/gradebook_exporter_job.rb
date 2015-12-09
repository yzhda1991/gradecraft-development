class GradebookExporterJob < ResqueJob::Base
  @queue = :gradebook_exporter 
  @exporter_class = GradebookExportPerformer
end
