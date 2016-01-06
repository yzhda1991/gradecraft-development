class SubmissionsExportJob < ResqueJob::Base
  @queue = :submissions_exports
  @performer_class = SubmissionsExportPerformer
end
