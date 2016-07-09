class CourseAnalyticsExportsMailer < ApplicationMailer
  layout "mailers/exports_layout"

  attr_reader :professor, :course, :export, :status

  # the SecureTokenHelper brings in the #secure_downloads_url method which we
  # need for building the secure download method on success emails
  add_template_helper(SecureTokenHelper)

  def export_started(professor:, course:)
    @professor = professor
    @course = course

    send_mail status: "is being created"
  end

  def export_failure(professor:, course:)
    @professor = professor
    @course = course

    send_mail status: "failed to build"
  end

  def export_success(professor:, export:, token:)
    @professor = professor
    @export = export
    @course = export.course
    @secure_token = token

    send_mail status: "is ready"
  end

  protected

  def send_mail(status:)
    @status = status

    mail mailer_attrs do |format|
      format.text
      format.html
    end
  end

  def mailer_attrs
    { to: professor.email, bcc: ADMIN_EMAIL, subject: subject }
  end

  def subject
    "Course Analytics Export for " \
      "#{course.courseno} - #{course.name} #{status}"
  end
end
