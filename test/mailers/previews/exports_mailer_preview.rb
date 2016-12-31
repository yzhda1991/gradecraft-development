class ExportsMailerPreview < ActionMailer::Preview
  
  def submissions_export_started(professor, assignment)
    mail_submissions_export("is being created", professor, assignment)
  end

  def submissions_export_success(professor, assignment, submissions_export,
                                 secure_token)
    cache_success_mailer_attrs(submissions_export, secure_token)
    mail_submissions_export("is ready", professor, assignment)
  end

  def submissions_export_failure(professor, assignment)
    mail_submissions_export("failed to build", professor, assignment)
  end

  def team_submissions_export_started(professor, assignment, team)
    mail_team_submissions_export("is being created", professor, assignment, team)
  end

  def team_submissions_export_success(professor, assignment, team,
                                      submissions_export, secure_token)
    cache_success_mailer_attrs(submissions_export, secure_token)
    mail_team_submissions_export("is ready", professor, assignment, team)
  end

  def team_submissions_export_failure(professor, assignment, team)
    mail_team_submissions_export("failed to build", professor, assignment, team)
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
      User.first,
      "gradebook export", # export type
      course.assignments.to_csv
    )
  end
end
