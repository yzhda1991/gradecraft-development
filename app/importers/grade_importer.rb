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
          if student.nil?
            append_unsuccessful row, "Student not found in course"
            next
          end
          if !has_grade?(row)
            append_unsuccessful row, "Grade not specified"
            next
          end

          grade = assignment.all_grade_statuses_grade_for_student(student)
          grade = update_grade row, grade if grade
          grade ||= create_grade row, assignment, student

          if grade.valid?
            successful << grade
          else
            append_unsuccessful row, grade.errors.full_messages.join(", ")
          end
        end
      end
    end

    self
  end

  private

  def append_unsuccessful(row, errors)
    unsuccessful << { data: row.to_s, errors: errors }
  end

  def has_grade?(row)
    row[3].present?
  end

  def assign_grade(row, grade)
    grade.raw_score = row[3].to_i
    grade.feedback = row[4]
    grade.status = "Graded" if grade.status.nil?
    grade.instructor_modified = true
  end

  def create_grade(row, assignment, student)
    assignment.grades.create do |grade|
      grade.student_id = student.id
      assign_grade row, grade
    end
  end

  def update_grade(row, grade)
    assign_grade row, grade
    grade.save
    grade
  end

  def find_student(row, students)
    students.find { |student| student.email.downcase == row[2].downcase }
  end
end
