class CourseAnalyticsExportsMailer < ApplicationMailer
  layout "mailers/notification_layout"

  attr_reader :owner, :course, :export, :status

  # the SecureTokenHelper brings in the #secure_downloads_url method which we
  # need for building the secure download method on success emails
  add_template_helper(SecureTokenHelper)

  def export_failure(export:)
    @owner = export.owner
    @course = export.course

    send_mail status: "failed to build"
  end

  def export_success(export:, token:)
    @owner = export.owner
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
    { to: owner.email, bcc: ADMIN_EMAIL, subject: subject }
  end

  def subject
    "Course Analytics Export for " \
      "#{course.course_number} - #{course.name} #{status}"
  end
end
