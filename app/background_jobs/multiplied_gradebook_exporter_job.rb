class MultipliedGradebookExporterJob < ResqueJob::Base
  @queue = :multiplied_gradebook_exporter
  @performer_class = MultipliedGradebookExportPerformer
end
