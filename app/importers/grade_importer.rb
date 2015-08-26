class GradeImporter
  attr_reader :successful, :unsuccessful

  def initialize(file)
    @successful = []
    @unsuccessful = []
  end

  def import
    self
  end
end
