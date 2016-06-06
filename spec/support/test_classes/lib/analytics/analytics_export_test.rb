require 'analytics'

class AnalyticsExportTest
  include Analytics::Export

  rows_by :fossils
  set_schema dinosaurs: :waffles
end
