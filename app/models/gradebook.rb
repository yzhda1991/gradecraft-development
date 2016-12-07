class Gradebook
  attr_reader :assignment, :students

  def initialize(assignment, *students)
    @assignment = assignment
    @students = [students].flatten
  end

  def grade(student)
    existing_grades.find { |g| g.assignment_id = assignment.id && g.student_id == student.id }
  end

  def existing_grades
    @existing_grades ||= Grade.where(assignment_id: assignment.id, student_id: students.map(&:id))
  end
end
