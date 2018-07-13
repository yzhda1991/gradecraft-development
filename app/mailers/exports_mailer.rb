class ExportsMailer < ApplicationMailer
  include EnvironmentHelper

  layout "mailers/notification_layout"

  # the SecureTokenHelper brings in the #secure_downloads_url method which we
  # need for building the secure download method on success emails
  add_template_helper(SecureTokenHelper)

  def submission_export(course, user, filename, csv_data)
    set_export_ivars(course, user)
    attachments["#{ course.name } Submissions - #{ Date.today }.csv"] = csv_attachment(csv_data)
    send_export_email "Submission export for #{ course.name } is attached"
  end

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

  def grade_export(course, user, csv_data)
    set_export_ivars(course, user)
    attachments["#{ course.name } Grades - #{ Date.today }.csv"] = csv_attachment(csv_data)
    send_export_email "Grade export for #{course.name} is attached"
  end

  def gradebook_export(course, user, filename, csv_data)
    set_export_ivars(course, user)
    attachments["#{ course.name } Grades - #{ Date.today }.csv"] = csv_attachment(csv_data)
    send_export_email "Gradebook export for #{ course.name } is attached"
  end

  def created_courses_export(csv)
    @dates = { today: Date.today.strftime("%B %d, %Y"), last_month: 1.month.ago.strftime("%B %d, %Y") }
    attachments["export.csv"] = csv_attachment(csv)
    mail(to: ADMIN_EMAIL, subject: "Your monthly course report for #{environment_to_readable_s}") do |format|
      format.text
      format.html
    end
  end

  private

  def set_export_ivars(course, user)
    @course = course
    @user = user
  end

  def csv_attachment(content)
    { mime_type: "text/csv", content: content }
  end

  def send_export_email(subject)
    mail(to: @user.email, bcc: ADMIN_EMAIL, subject: subject) do |format|
      format.html
      format.text
    end
  end

  def mail_submissions_export(message, professor, assignment)
    cache_submission_attrs(professor, assignment)
    mail_message_with_subject "Submissions export for #{@course.assignment_term.downcase} #{@assignment.name} #{message}"
  end

  def mail_team_submissions_export(message, professor, assignment, team)
    cache_team_submission_attrs(professor, assignment, team)
    mail_message_with_subject "Submissions export for #{@course.team_term.downcase} #{@team.name} #{message}"
  end

  def mail_message_with_subject(subject)
    mail(default_attrs.merge(subject: subject)) do |format|
      format.text
      format.html
    end
  end

  def default_attrs
    {
      to: @professor.email,
      bcc: ExportsMailer::ADMIN_EMAIL
    }
  end

  def cache_success_mailer_attrs(submissions_export, secure_token)
    @submissions_export = submissions_export
    @secure_token = secure_token
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
