class SubmissionExporter
  def export(course)
    CSV.generate do |csv|
      csv << baseline_headers
      course.submissions.submitted.each do |submission|
        csv << [ submission.id, submission.assignment_id, submission.assignment.name,
          submission.student.email, submission.student_id, submission.group_id, submission.text_comment, submission.created_at, submission.updated_at, submission.grade.try(:score), submission.grade.try(:feedback), submission.grade.try(:graded_at) ]
      end
    end
  end

  private

  def baseline_headers
    ["Submission ID", "Assignment ID", "Assignment Name", "Student Email", "Student ID", "Group ID", "Student Comment", "Created At", "Updated At", "Score", "Grader Feedback", "Grade Last Updated"]
  end
end
