class SubmissionExporter
  def export(course)
    CSV.generate do |csv|
      csv << baseline_headers
      course.submissions.each do |submission|
        grade = submission.student.grade_for_assignment(submission.assignment)
        csv << [ submission.id, submission.assignment_id, submission.assignment.name,
          submission.student_id, submission.group_id, submission.text_comment, submission.created_at, submission.updated_at, grade.score || "", grade.feedback || "", grade.updated_at ]
      end
    end
  end

  private

  def baseline_headers
    ["Submission ID", "Assignment ID", "Assignment Name", "Student ID", "Group ID", "Student Comment", "Created At", "Updated At", "Score", "Grader Feedback", "Grade Last Updated"]
  end
end
