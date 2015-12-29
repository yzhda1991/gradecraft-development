class ExportsMailer < ApplicationMailer
  layout "mailers/exports_layout"

  def submissions_export_started(professor, assignment)
    cache_submission_attrs(professor, assignment)
    mail(default_attrs.merge(:subject => "Submissions export for #{@course.assignment_term.downcase} #{@assignment.name} is being created")) do |format|
      format.text
      format.html
    end
  end

  def submissions_export_success(professor, assignment)
    cache_submission_attrs(professor, assignment)
    mail(default_attrs.merge(:subject => "Submissions export for #{@course.assignment_term.downcase} #{@assignment.name} is ready")) do |format|
      format.text
      format.html
    end
  end

  def submissions_export_failure(professor, assignment)
    cache_submission_attrs(professor, assignment)
    mail(default_attrs.merge(:subject => "Submissions export for #{@course.assignment_term.downcase} #{@assignment.name} failed to build")) do |format|
      format.text
      format.html
    end
  end

  def team_submissions_export_started(professor, assignment, team)
    cache_team_submission_attrs(professor, assignment, team)
    mail(default_attrs.merge(:subject => "Submissions export for #{@course.team_term.downcase} #{@team.name} is being created")) do |format|
      format.text
      format.html
    end
  end

  def team_submissions_export_success(professor, assignment, team)
    cache_team_submission_attrs(professor, assignment, team)
    mail(default_attrs.merge(:subject => "Submissions export for #{@course.team_term.downcase} #{@team.name} is ready")) do |format|
      format.text
      format.html
    end
  end

  def team_submissions_export_failure(professor, assignment, team)
    cache_team_submission_attrs(professor, assignment, team)
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
