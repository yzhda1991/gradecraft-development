class Gradebook
  attr_reader :assignment, :students

  def initialize(assignment, *students)
    @assignment = assignment
    @students = [students].flatten
  end

  def grade(student)
    existing_grades.find { |g| g.assignment_id = assignment.id && g.student_id == student.id }
  end

  def grades
    (existing_grades + missing_grades).sort_by { |grade| [grade.student.last_name,
                                                          grade.student.first_name] }
  end

  def existing_grades
    @existing_grades ||= Grade.where(assignment_id: assignment.id, student_id: students.map(&:id))
  end

  private

  def missing_grades
    students_without_grades.map { |s| Grade.new(assignment_id: assignment.id, student_id: s.id) }
  end

  def students_without_grades
    students.reject { |s| existing_grades.map(&:student_id).include?(s.id) }
  end
end
