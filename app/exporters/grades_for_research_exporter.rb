
  # todo: needs to be refactored as a CSV exporter
  def research_grades_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["Course ID", "Uniqname", "First Name", "Last Name", "GradeCraft ID", "Assignment Name", "Assignment ID", "Assignment Type", "Assignment Type Id", "Score", "Assignment Point Total", "Multiplied Score", "Predicted Score", "Text Feedback", "Submission ID", "Submission Creation Date", "Submission Updated Date", "Graded By", "Created At", "Updated At"]
      self.grades.each do |grade|
        csv << [self.id, grade.student.username, grade.student.first_name, grade.student.last_name, grade.student_id, grade.assignment.name, grade.assignment.id, grade.assignment.assignment_type.name, grade.assignment.assignment_type_id, grade.raw_score, grade.point_total, grade.score, grade.predicted_score, grade.feedback, grade.submission_id, grade.submission.try(:created_at), grade.submission.try(:updated_at), grade.graded_by_id, grade.created_at, grade.updated_at]
      end
    end
  end
