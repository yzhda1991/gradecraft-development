require_relative "grade_proctor/base"
require_relative "grade_proctor/updatable"
require_relative "grade_proctor/viewable"

class GradeProctor
  include Updatable
  include Viewable

  attr_reader :resource

  def initialize(resource)
    @resource = resource
  end
end
