class MultipleGradeUpdaterJob < ResqueJob::Base
  @queue = :multiple_grade_updater
  @performer_class = MultipleGradeUpdatePerformer
end
