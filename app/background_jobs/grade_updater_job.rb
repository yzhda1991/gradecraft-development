class GradeUpdaterJob < ResqueJob::Base
  @queue = :grade_updater
  @performer_class = GradeUpdatePerformer
end
