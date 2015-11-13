class AssignmentExporter
  def export(assignment, students, options={})
    CSV.generate(options) do |csv|
      csv << headers
      students.each do |student|
        grade = student.grade_for_assignment(assignment)
        submission = student.submission_for_assignment(assignment)
        if grade and (grade.instructor_modified? || grade.graded_or_released?)
          csv << [student.first_name, student.last_name,
                  student.username, grade.try(:score) || "", grade.try(:raw_score) || "",
                  submission.try(:text_comment) || "", grade.try(:feedback) || "",
                  grade.try(:updated_at) || ""]
        end
      end
    end
  end

  private

  def headers
    ["First Name", "Last Name", "Uniqname", "Score", "Raw Score",
     "Statement", "Feedback", "Last Updated"].freeze
  end
end
