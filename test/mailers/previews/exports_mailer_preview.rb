class ExportsMailerPreview < ActionMailer::Preview
  
  def submissions_export_started
    assignment = Assignment.first
    professor = User.with_role_in_courses("professor", Course.first).first
    ExportsMailer.submissions_export_started professor, assignment
  end
  
  def submissions_export_success
    assignment = Assignment.first
    professor = User.with_role_in_courses("professor", Course.first).first
    submissions_export = SubmissionsExport.first
    secure_token = SecureToken.first
    ExportsMailer.submissions_export_success professor, assignment, submissions_export, secure_token
  end
  
  def submissions_export_failure
    assignment = Assignment.first
    professor = User.with_role_in_courses("professor", Course.first).first
    ExportsMailer.submissions_export_failure professor, assignment
  end
  
  def team_submissions_export_started
    assignment = Assignment.first
    professor = User.with_role_in_courses("professor", Course.first).first
    team = Team.first
    ExportsMailer.team_submissions_export_started professor, assignment, team
  end
  
  def team_submissions_export_success    
    professor = User.with_role_in_courses("professor", Course.first).first
    assignment = Assignment.first
    team = Team.first
    submissions_export = SubmissionsExport.first
    secure_token = SecureToken.first
    ExportsMailer.team_submissions_export_success professor, assignment, team, submissions_export, secure_token
  end
  
  def team_submissions_export_failure
    professor = User.with_role_in_courses("professor", Course.first).first
    assignment = Assignment.first
    team = Team.first
    ExportsMailer.team_submissions_export_failure professor, assignment, team
  end
  
  def grade_export
    course = Course.first
    ExportsMailer.grade_export(
      course,
      user = User.first,
      csv_data = course.assignments.to_a.to_csv
    )
    ExportsMailer.grade_export course, user, csv_data
  end
  
  def gradebook_export
    course = Course.first
    ExportsMailer.gradebook_export(
      course,
      user = User.first,
      csv_data = course.assignments.to_a.to_csv
    )
    ExportsMailer.gradebook_export course, user, "gradebook_export", csv_data
  end
end
