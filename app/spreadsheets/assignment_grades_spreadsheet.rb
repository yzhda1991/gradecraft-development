class AssignmentGradesSpreadsheet
  def initialize(new)
    
  end

  attr_reader :grade

  def heading
    ["First Name", "Last Name", "Email", "Score", "Feedback"]
  end

  def build_rows_by_student
    @students.each
  end

  def grade_modified_or_released?
   grade and (grade.instructor_modified? || grade.graded_or_released?)
  end
end
  def grade_import(students, options = {})
    CSV.generate(options) do |csv|
      csv << ["First Name", "Last Name", "Email", "Score", "Feedback"]
      students.each do |student|
        grade = student.grade_for_assignment(self)
        if grade and (grade.instructor_modified? || grade.graded_or_released?)
          csv << [student.first_name, student.last_name, student.email, student.grade_for_assignment(self).score, student.grade_for_assignment(self).try(:feedback) ]
        else
          csv << [student.first_name, student.last_name, student.email, "", "" ]
        end
      end
    end
  end

