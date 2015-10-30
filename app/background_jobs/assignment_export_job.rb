class AssignmentExportJob < ResqueJob::Base
  @queue = :assignment_exports
  @performer_class = AssignmentExportPerformer
end
