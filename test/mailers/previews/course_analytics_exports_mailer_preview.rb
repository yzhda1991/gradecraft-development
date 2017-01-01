class CourseAnalyticsExportsPreview < ActionMailer::Preview
  def export_failure
    @owner = User.first
    @course = Course.first

    CourseAnalyticsExportsMailer.export_failure status: "failed to build"
  end

  def export_success
    @owner = User.first
    @course = Course.first
    @export = export
    @secure_token = token

    CourseAnalyticsExportsMailer.export_failure status: "is ready"
  end
end
