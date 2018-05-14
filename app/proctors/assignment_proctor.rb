class AssignmentProctor
  attr_reader :assignment

  def initialize(assignment)
    @assignment = assignment
  end

  def viewable?(user)
    return true if user.is_staff?(@assignment.course)
    @assignment.visible_for_student?(user)
  end

end
