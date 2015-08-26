require 'csv'

class GradeImporter
  attr_reader :successful, :unsuccessful
  attr_accessor :file

  def initialize(file)
    @file = file
    @successful = []
    @unsuccessful = []
  end

  def import(course=nil, assignment=nil)
    if file
      if course && assignment
        students = course.students
        CSV.foreach(file, headers: true, encoding: 'ISO-8859-1') do |row|
          student = find_student(row, students)
          if student
            if has_grade?(row)
              grade = create_grade row, assignment, student
            end
          end
        end
      end
    end

    self
  end

  private

  def has_grade?(row)
    row[3].present?
  end

  def create_grade(row, assignment, student)
    assignment.grades.create do |grade|
      grade.student_id = student.id
      grade.raw_score = row[3].to_i
      grade.feedback = row[4]
      grade.status = "Graded"
      grade.instructor_modified = true
    end
  end

  def find_student(row, students)
    students.find { |student| student.email.downcase == row[2].downcase }
  end
end
