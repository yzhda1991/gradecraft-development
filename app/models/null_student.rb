class NullStudent
  attr_accessor :course, :grades

  def initialize(course=nil)
    @course = course
    @grades = NullStudentGrades.new
  end

  def id
    0
  end

  def submission_for_assignment(*)
    self
  end

  def weight_for_assignment_type(*)
    0
  end

  def present?
    false
  end

  def team_for_course(*)
    NullTeam.new
  end
end


class NullStudentGrades

  def where(*)
    self
  end

  def select(*)
    self
  end

  def first
    NullGrade.new
  end
end

class NullTeam
  def id
    0
  end
  def challenge_grades
    NullStudentGrades.new
  end
end
