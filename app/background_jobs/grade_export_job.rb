# todo: need to add specs for the GradeExportJob subclass
class GradeExportJob < ResqueJob::Base
  @queue = :grade_exporter
  @performer_class = GradeExportPerformer
  @logger = Logglier.new("https://logs-01.loggly.com/inputs/#{ENV['LOGGLY_TOKEN']}/tag/grade-export-job-queue", threaded: true, format: :json)
end
