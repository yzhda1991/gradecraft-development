class Gradebook
  attr_reader :students

  def initialize(*students)
    @students = [students].flatten
  end

  def grade(student)
    grades.find { |g| g.student_id == student.id }
  end

  def grades
    @grades ||= Grade.where(student_id: students.map(&:id))
  end
end
