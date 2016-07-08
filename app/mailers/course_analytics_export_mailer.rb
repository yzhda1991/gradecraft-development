class CourseAnalyticsExportsMailer < ApplicationMailer
  layout "mailers/exports_layout"

  attr_accessor :professor, :course, :export, :status

  # the SecureTokenHelper brings in the #secure_downloads_url method which we
  # need for building the secure download method on success emails
  add_template_helper(SecureTokenHelper)

  def export_started(professor:, course:)
    self.professor = professor
    self.course = course

    send_mail status: "is being created"
  end

  def export_success(professor:, export:, token:)
    self.professor = professor
    self.export = export
    self.secure_token = token

    send_mail status: "is ready"
  end

  def export_failure(professor:, course:)
    self.professor = professor
    self.course = course

    send_mail status: "failed to build"
  end

  protected

  def send_mail(status:)
    self.status = status

    mail mailer_attrs do |format|
      format.text
      format.html
    end
  end

  def mailer_attrs
    { to: professor.email, bcc: ADMIN_EMAIL, subject: subject.call }
  end

  def subject
    Proc.new do
      "Course Analytics Export for " \
        "#{course.courseno} - #{course.name} #{status}"
    end
  end
end
