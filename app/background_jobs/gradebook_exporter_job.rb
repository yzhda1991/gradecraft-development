class GradebookExporterJob < ResqueJob::Base
  @queue = :gradebook_exporter 
  @performer_class = GradebookExportPerformer
end
