class ExportsMailer < ApplicationMailer
  layout "mailers/exports_layout"

  def submissions_export_started(professor, assignment, archive_data)
    cache_submission_attrs(professor, assignment, archive_data)
    mail(default_attrs.merge(:subject => "Submissions export for #{@assignment.name} is being created")) do |format|
      format.text
      format.html
    end
  end

  def submissions_export_success(professor, assignment, archive_data)
    cache_submission_attrs(professor, assignment, archive_data)
    mail(default_attrs.merge(:subject => "Submissions export for assignment #{@assignment.name} is ready")) do |format|
      format.text
      format.html
    end
  end

  def submissions_export_failure(professor, assignment, archive_data)
    cache_submission_attrs(professor, assignment, archive_data)
    mail(default_attrs.merge(:subject => "Submissions export for assignment #{@assignment.name} failed to build")) do |format|
      format.text
      format.html
    end
  end

  def team_submissions_export_started(professor, assignment, team, archive_data)
    cache_team_submission_attrs(professor, assignment, team, archive_data)
    mail(default_attrs.merge(:subject => "Submissions export for #{@course.team_term.downcase} #{@team.name} is being created")) do |format|
      format.text
      format.html
    end
  end

  def team_submissions_export_success(professor, assignment, team, archive_data)
    cache_team_submission_attrs(professor, assignment, team, archive_data)
    mail(default_attrs.merge(:subject => "Submissions export for #{@course.team_term.downcase} #{@team.name} is ready")) do |format|
      format.text
      format.html
    end
  end

  def team_submissions_export_failure(professor, assignment, team, archive_data)
    cache_team_submission_attrs(professor, assignment, team, archive_data)
    mail(default_attrs.merge(:subject => "Submissions export for #{@course.team_term.downcase} #{@team.name} failed to build")) do |format|
      format.text
      format.html
    end
  end

  private

  def default_attrs
    {
      to: @professor.email,
      bcc: ExportsMailer::ADMIN_EMAIL
    }
  end

  def cache_submission_attrs(professor, assignment, archive_data)
    @professor = professor
    @assignment = assignment
    @course = assignment.course
    @archive_data = archive_data
  end

  def cache_team_submission_attrs(professor, assignment, team, archive_data)
    @professor = professor
    @assignment = assignment
    @course = assignment.course
    @team = team
    @archive_data = archive_data
  end
end
