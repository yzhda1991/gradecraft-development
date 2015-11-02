class ExportsMailer < ApplicationMailer

  def submissions_export_success(user, assignment)
    cache_submission_attrs(user, assignment)
    mail(default_attrs.merge(:subject => "Submissions export for assignment #{@assignment.name} is ready.")) do |format|
      format.text
      format.html
    end
  end

  def submissions_export_failure(user, assignment)
    cache_submission_attrs(user, assignment)
    mail(default_attrs.merge(:subject => "Submissions export for assignment #{@assignment.name} failed.")) do |format|
      format.text
      format.html
    end
  end

  def team_submissions_export_success(user, assignment, team)
    cache_team_submission_attrs(user, assignment, team)
    mail(default_attrs.merge(:subject => "Submissions export for team #{@team.name} is ready.")) do |format|
      format.text
      format.html
    end
  end

  def team_submissions_export_failed(user, assignment, team)
    cache_team_submission_attrs(user, assignment, team)
    mail(default_attrs.merge(:subject => "Submissions export for team #{@team.name} failed.")) do |format|
      format.text
      format.html
    end
  end

  private

  def default_attrs
    {
      :to =>  @user.email,
      :bcc=>"admin@gradecraft.com"
    }
  end

  def cache_submission_attrs(user, assignment)
    @user = user
    @assignment = assignment
  end

  def cache_team_submission_attrs(user, assignment, team)
    @user = user
    @assignment = assignment
    @team = team
  end
end
