require 'analytics'

class AnalyticsExportModelTest < Analytics::Export::Model

  column_mapping dinosaurs: :waffles

  def initialize(loaded_data)
    @loaded_data = loaded_data
  end

  def waffles(record)
    { some: "waffles" }
  end
end
