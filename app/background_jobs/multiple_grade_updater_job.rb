class MultipleGradeUpdaterJob < ResqueJob::Base
  @queue = :grade_updater
  @performer_class = MultipleGradeUpdatePerformer
  @logger = Logglier.new("https://logs-01.loggly.com/inputs/#{ENV['LOGGLY_TOKEN']}/tag/multiple-grade-updater-job-queue", threaded: true, format: :json)
end
