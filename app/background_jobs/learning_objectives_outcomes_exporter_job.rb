class LearningObjectivesOutcomesExporterJob < ResqueJob::Base
  @queue = :learning_objectives_outcomes_exporter
  @performer_class = LearningObjectivesOutcomesExportPerformer
end
