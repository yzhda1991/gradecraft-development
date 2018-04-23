class AssignmentProctor
  attr_reader :assignment

  def initialize(assignment)
    @assignment = assignment
  end

  def viewable?(user, course)
    return true if @assignment.visible?
    return true if user.is_staff?(course) || user.is_admin?(course)
    return false
  end
end
