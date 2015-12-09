class AssignmentExporter
  def export_grades(assignment, students, options={})
    CSV.generate(options) do |csv|
      csv << headers
      students.each do |student|
        grade = student.grade_for_assignment(assignment)
        grade = NullGrade.new if grade.nil? || !(grade.instructor_modified? || grade.graded_or_released?)
        submission = student.submission_for_assignment(assignment)
        csv << [student.first_name, student.last_name,
                student.username, grade.score || "", grade.raw_score || "",
                submission.try(:text_comment) || "", grade.feedback || "",
                grade.updated_at || ""]
      end
    end
  end

  private

  def headers
    ["First Name", "Last Name", "Uniqname", "Score", "Raw Score",
     "Statement", "Feedback", "Last Updated"].freeze
  end
end
