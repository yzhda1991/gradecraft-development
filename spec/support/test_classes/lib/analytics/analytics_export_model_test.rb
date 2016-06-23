require 'analytics'

class AnalyticsExportModelTest
  include Analytics::Export::Model

  rows_by :fossils
  set_schema dinosaurs: :waffles

  def initialize(loaded_data)
    @loaded_data = loaded_data
  end

  def waffles(record)
    { some: "waffles" }
  end
end
