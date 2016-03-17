require_relative "grade_proctor/base"
require_relative "grade_proctor/updatable"
require_relative "grade_proctor/viewable"

class GradeProctor
  include Updatable
  include Viewable

  attr_reader :grade

  def initialize(grade)
    @grade = grade
  end
end
