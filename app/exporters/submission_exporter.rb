class SubmissionExporter
  def export(course)
    CSV.generate do |csv|
      csv << baseline_headers
      course.submissions.each do |submission|
        csv << [ submission.id, submission.assignment_id, submission.assignment.name,
          submission.student_id, submission.student.try(:first_name), submission.student.try(:last_name), submission.text_comment, submission.created_at, submission.updated_at, submission.student.grade_for_assignment(submission.assignment).score || "", submission.student.grade_for_assignment(submission.assignment).feedback || "" ]
      end
    end
  end

  private

  def baseline_headers
    ["Submission ID", "Assignment ID", "Assignment Name", "Student ID", "First Name", "Last Name", "Comment", "Created At", "Updated At", "Score", "Feedback"]
  end
end
