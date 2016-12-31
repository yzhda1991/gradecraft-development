class ExportsMailerPreview < ActionMailer::Preview
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
end
