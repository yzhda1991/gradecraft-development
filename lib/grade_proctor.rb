require_relative "grade_proctor/viewable"

class GradeProctor
  include Viewable

  attr_reader :resource

  def initialize(resource)
    @resource = resource
  end
end
