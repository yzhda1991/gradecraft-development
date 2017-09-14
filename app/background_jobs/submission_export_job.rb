class SubmissionExportJob < ResqueJob::Base
  @queue = :submission_exporter
  @performer_class = SubmissionExportPerformer
end
