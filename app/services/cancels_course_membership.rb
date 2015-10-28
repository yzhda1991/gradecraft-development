class CancelsCourseMembership
  def self.for_student(membership)
    deletes_membership(membership)
      .removes_submissions(membership)
      .removes_grades(membership)
      .removes_rubric_grades(membership)
      .removes_assignment_weights(membership)
  end

  private

  def self.deletes_membership(membership)
    membership.destroy
    self
  end

  def self.removes_assignment_weights(membership)
    AssignmentWeight.for_course(membership.course)
      .for_student(membership.user)
      .destroy_all
    self
  end

  def self.removes_grades(membership)
    Grade.for_course(membership.course)
      .for_student(membership.user)
      .destroy_all
    self
  end

  def self.removes_submissions(membership)
    Submission.for_course(membership.course)
      .for_student(membership.user)
      .destroy_all
    self
  end

  def self.removes_rubric_grades(membership)
    RubricGrade.for_course(membership.course)
      .for_student(membership.user)
      .destroy_all
    self
  end
end
