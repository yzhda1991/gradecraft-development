class ExportsMailer < ApplicationMailer
  layout "mailers/exports_layout"

  def submissions_export_success(professor, assignment, archive_data)
    cache_submission_attrs(professor, assignment)
    mail(default_attrs.merge(:subject => "Submissions export for assignment #{@assignment.name} is ready.")) do |format|
      format.text
      format.html
    end
  end

  def submissions_export_failure(professor, assignment, archive_data)
    cache_submission_attrs(professor, assignment)
    mail(default_attrs.merge(:subject => "Submissions export for assignment #{@assignment.name} failed.")) do |format|
      format.text
      format.html
    end
  end

  def team_submissions_export_success(professor, assignment, team, archive_data)
    cache_team_submission_attrs(professor, assignment, team)
    mail(default_attrs.merge(:subject => "Submissions export for team #{@team.name} is ready.")) do |format|
      format.text
      format.html
    end
  end

  def team_submissions_export_failed(professor, assignment, team, archive_data)
    cache_team_submission_attrs(professor, assignment, team)
    mail(default_attrs.merge(:subject => "Submissions export for team #{@team.name} failed.")) do |format|
      format.text
      format.html
    end
  end

  private

  def default_attrs
    {
      to: @professor.email,
      bcc: ADMIN_EMAIL
    }
  end

  def cache_submission_attrs(professor, assignment)
    @professor = professor
    @assignment = assignment
  end

  def cache_team_submission_attrs(professor, assignment, team)
    @professor = professor
    @assignment = assignment
    @team = team
  end
end
