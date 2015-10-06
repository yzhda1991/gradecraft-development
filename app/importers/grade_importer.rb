require 'csv'

class GradeImporter
  attr_reader :successful, :unsuccessful, :unchanged
  attr_accessor :file

  def initialize(file)
    @file = file
    @successful = []
    @unsuccessful = []
    @unchanged = []
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
          if update_grade? row, grade
            grade = update_grade row, grade
            report row, grade
          elsif grade.present?
            unchanged << grade
          elsif grade.nil?
            grade = create_grade row, assignment, student
            report row, grade
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
    grade_column(row).present?
  end

  def assign_grade(row, grade)
    grade.raw_score = grade_column(row)
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

  def grade_column(row)
    row[3].to_i if row[3]
  end

  def update_grade?(row, grade)
    grade.present? && grade.raw_score != grade_column(row)
  end

  def update_grade(row, grade)
    assign_grade row, grade
    grade.save
    grade
  end

  def find_student(row, students)
    identifier = row[2].downcase
    if identifier =~ /@/
      students.find { |student| student.email.downcase == identifier }
    else
      students.find { |student| student.username.downcase == identifier }
    end
  end

  def report(row, grade)
    if grade.valid?
      successful << grade
    else
      append_unsuccessful row, grade.errors.full_messages.join(", ")
    end
  end
end
