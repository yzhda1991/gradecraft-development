class GradebookExporterJob < ResqueJob::Base
  @queue = :gradebook_exporter 
  @performer_class = GradebookExportPerformer
  @logger = Logglier.new("https://logs-01.loggly.com/inputs/#{ENV['LOGGLY_TOKEN']}/tag/gradebook-export-job-queue", threaded: true, format: :json)
end
