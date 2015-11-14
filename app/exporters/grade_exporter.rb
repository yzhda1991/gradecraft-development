class GradeExporter
  def export(assignment, students, options={})
    CSV.generate(options) do |csv|
      csv << headers
      students.each do |student|
        grade = student.grade_for_assignment(assignment) || NullGrade.new
        csv << [student.first_name, student.last_name,
                student.email, grade.score || "", grade.feedback || ""]
      end
    end
  end

  private

  def headers
    ["First Name", "Last Name", "Email", "Score", "Feedback"].freeze
  end
end
