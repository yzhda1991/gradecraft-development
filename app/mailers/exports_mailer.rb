class ExportsMailer < ApplicationMailer
  layout "mailers/exports_layout"

  def submissions_export_started(professor, assignment)
    mail_submissions_export("is being created", professor, assignment)
  end

  def submissions_export_success(professor, assignment, submissions_export)
    @submissions_export = submissions_export
    mail_submissions_export("is ready", professor, assignment)
  end

  def submissions_export_failure(professor, assignment)
    mail_submissions_export("failed to build", professor, assignment)
  end

  def team_submissions_export_started(professor, assignment, team)
    mail_team_submissions_export("is being created", professor, assignment, team)
  end

  def team_submissions_export_success(professor, assignment, team, submissions_export)
    @submissions_export = submissions_export
    mail_team_submissions_export("is ready", professor, assignment, team)
  end

  def team_submissions_export_failure(professor, assignment, team)
    mail_team_submissions_export("failed to build", professor, assignment, team)
  end

  private

  def mail_submissions_export(message, professor, assignment)
    cache_submission_attrs(professor, assignment)
    mail_message_with_subject "Submissions export for #{@course.assignment_term.downcase} #{@assignment.name} #{message}"
  end

  def mail_team_submissions_export(message, professor, assignment, team)
    cache_team_submission_attrs(professor, assignment, team)
    mail_message_with_subject "Submissions export for #{@course.team_term.downcase} #{@team.name} #{message}"
  end

  def mail_message_with_subject(subject)
    mail(default_attrs.merge(:subject => subject) do |format|
      format.text
      format.html
    end
  end

  def mail_message_with_subject(subject)
  end

  def default_attrs
    {
      to: @professor.email,
      bcc: ExportsMailer::ADMIN_EMAIL
    }
  end

  def cache_submission_attrs(professor, assignment)
    @professor = professor
    @assignment = assignment
    @course = assignment.course
  end

  def cache_team_submission_attrs(professor, assignment, team)
    @professor = professor
    @assignment = assignment
    @course = assignment.course
    @team = team
  end
end
  end

  def default_attrs
    {
      to: @professor.email,
      bcc: ExportsMailer::ADMIN_EMAIL
    }
  end

  def cache_submission_attrs(professor, assignment)
    @professor = professor
    @assignment = assignment
    @course = assignment.course
  end

  def cache_team_submission_attrs(professor, assignment, team)
    @professor = professor
    @assignment = assignment
    @course = assignment.course
    @team = team
  end
end
