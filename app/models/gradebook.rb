class Gradebook
  attr_reader :assignment, :students

  def initialize(assignment, *students)
    @assignment = assignment
    @students = [students].flatten
  end

  def grade(student)
    grades.find { |g| g.assignment_id = assignment.id && g.student_id == student.id }
  end

  def grades
    @grades ||= Grade.where(assignment_id: assignment.id, student_id: students.map(&:id))
  end
end
