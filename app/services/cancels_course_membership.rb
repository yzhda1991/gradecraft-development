class CancelsCourseMembership
  def self.for_student(membership)
    deletes_membership(membership)
      .removes_grades(membership.user)
      .removes_rubric_grades(membership.user)
  end

  private

  def self.deletes_membership(membership)
    membership.destroy
    self
  end

  def self.removes_grades(student)
    Grade.for_student(student).destroy_all
    self
  end

  def self.removes_rubric_grades(student)
    RubricGrade.for_student(student).destroy_all
    self
  end
end
