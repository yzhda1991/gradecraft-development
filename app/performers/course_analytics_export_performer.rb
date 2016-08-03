class CourseAnalyticsExportPerformer < ResqueJob::Performer
  attr_reader :export, :owner, :course

  def setup
    @export = CourseAnalyticsExport.find attrs[:export_id]
    @owner = @export.owner
    @course = @export.course

    export.update_export_started_time
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    build_the_export
    deliver_mailer

    export.update_export_completed_time
  end

  def deliver_mailer
    mailer = export.s3_object_exists? ? success_mailer : failure_mailer
    mailer.deliver_now

    export.update_attributes last_completed_step: "deliver_mailer"
  end

  def success_mailer
    token = export.generate_secure_token
    CourseAnalyticsExportsMailer.export_success export: export, token: token
  end

  def failure_mailer
    CourseAnalyticsExportsMailer.export_failure export: export
  end

  private

  def build_the_export
    begin
      export.build_archive!
    ensure
      # once we've successfully built the export on s3fs, let's upload it
      export.upload_builder_archive_to_s3
      export.update_attributes last_completed_step: "build_the_export"
    end
  end
end
