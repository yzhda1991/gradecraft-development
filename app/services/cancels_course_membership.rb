class CancelsCourseMembership
  def self.for_student(membership)
    removes_grades(membership.user)
  end

  private

  def self.removes_grades(student)
    Grade.for_student(student).destroy_all
    self
  end
end
