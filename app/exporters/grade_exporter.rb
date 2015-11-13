class GradeExporter
  def export(assignment, students, options={})
    data = CSV.generate(options) do |csv|
      csv << headers
      students.each do |student|
        grade = student.grade_for_assignment(assignment)
        csv << [student.first_name, student.last_name,
                student.email, grade.try(:score) || "", grade.try(:feedback) || ""]
      end
    end
    CSV.new data
  end

  private

  def headers
    ["First Name", "Last Name", "Email", "Score", "Feedback"].freeze
  end
end
