class GradeExportJob < ResqueJob::Base
  @queue = :grade_exporter
  @performer_class = GradeExportPerformer
end
