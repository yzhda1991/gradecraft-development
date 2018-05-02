class SubmissionExporter
  def export(course)
    CSV.generate do |csv|
      csv << baseline_headers(course)
      course.submissions.submitted.each do |submission|
        csv << [ submission.id, submission.assignment.assignment_type.name, submission.assignment_id, submission.assignment.name,
          submission.student.try(:email), submission.student_id, submission.group.try(:name), find_team_name(submission), submission.text_comment, submission.created_at, submission.updated_at, submission.grade.try(:score), find_graded_by_name(submission.grade.try(:graded_by_id)), submission.grade.try(:feedback), submission.grade.try(:graded_at) ]
      end
    end
  end

  private

  def baseline_headers(course)
    [
      "Submission ID", "#{course.assignment_term} Type",
      "#{course.assignment_term} ID", "#{course.assignment_term} Name",
      "#{course.student_term} Email", "#{course.student_term} ID",
      "#{course.group_term} Name", "#{course.team_term} Name",
      "#{course.student_term} Comment", "Created At", "Updated At", "Score",
      "Graded By", "Grader Feedback", "Grade Last Updated"
    ]
  end

  def find_graded_by_name(graded_by_id)
    return nil unless !graded_by_id.nil?
    User.find(graded_by_id).name
  end

  def find_team_name(submission)
    return nil unless submission.student.present?
    submission.student.team_for_course(submission.course).try(:name)
  end
end
