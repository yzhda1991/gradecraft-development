class ExportsMailer < ActionMailer::Base
  default from: 'mailer@gradecraft.com'

  def submissions_export_success
    mail(default_attrs.merge(:subject => "Submissions export for assignment #{@assignment.name} is ready.")) do |format|
      format.text
      format.html
    end
  end

  def submissions_export_failure
    mail(default_attrs.merge(:subject => "Submissions export for assignment #{@assignment.name} failed.")) do |format|
      format.text
      format.html
    end
  end

  def team_submissions_export_success
    mail(default_attrs.merge(:subject => "Submissions export for team #{@team.name} is ready.")) do |format|
      format.text
      format.html
    end
  end

  def team_submissions_export_failed
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
end
