# todo: need to add specs for the GradeExportJob subclass
class GradeExportJob < ResqueJob::Base
  @queue = :grade_exporter
  @performer_class = GradeExportPerformer
end
