require 'analytics'

class AnalyticsExportTest
  include Analytics::Export::Model

  rows_by :fossils
  set_schema dinosaurs: :waffles
end
