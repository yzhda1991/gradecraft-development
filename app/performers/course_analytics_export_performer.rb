class CourseAnalyticsExportPerformer < ResqueJob::Performer
  attr_reader :export, :professor, :course

  def setup
    @export = CourseAnalyticsExport.find attrs[:export_id]
    @professor = @export.professor
    @course = @export.course

    export.update_export_started_time
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    build_the_export
    # deliver_mailer
    # export.update_export_completed_time
  end

  def deliver_mailer
    mailer = export.s3_object_exists? ? success_mailer : failure_mailer
    mailer.deliver_now

    export.update_attributes last_completed_step: "deliver_mailer"
  end

  def success_mailer
    CourseAnalyticsExportsMailer.course_analytics_export_success \
      professor,
      export,
      secure_token
  end

  def failure_mailer
    CourseAnalyticsExportsMailer.course_analytics_export_failure \
      professor,
      export
  end

  def secure_token
    @secure_token ||= SecureToken.create \
      user_id: professor[:id],
      course_id: course[:id],
      target: export
  end

  private

  # this was ripped directly out of AnalyticsController#export and will not
  # be tested or modified on this branch. see branch:
  # 2118-
  #
  def build_the_export
    # check whether we need to use S3fs
    use_s3fs = %w[staging production].include? Rails.env

    # if we do use the prefix for the s3fs tempfiles
    s3fs_prefix = use_s3fs ? "/s3mnt/tmp/#{Rails.env}" : nil

    # create a working tmpdir for the export
    export_tmpdir = Dir.mktmpdir nil, s3fs_prefix

    # create a named directory to generate the files in
    export_dir = FileUtils.mkdir \
      File.join(export_tmpdir, export.formatted_course_number)

    id = course.id

    begin
      events = Analytics::Event.where(course_id: id)

      predictor_events =
        Analytics::Event.where(course_id: id, event_type: "predictor")

      user_pageviews = CourseUserPageview.data(:all_time, nil, {
        course_id: id
        },
        { page: "_all" })

      user_predictor_pageviews =
        CourseUserPagePageview.data(:all_time, nil, {
        course_id: id, page: /predictor/
        })

      user_logins = CourseUserLogin.data(:all_time, nil, {
        course_id: id
        })

      user_ids = events.collect(&:user_id).compact.uniq

      assignment_ids = events.select {
        |event| event.respond_to? :assignment_id
      }.collect(&:assignment_id).compact.uniq

      users = User.where(id: user_ids).select(:id, :username)

      assignments =
        Assignment.where(id: assignment_ids).select(:id, :name)

      data = {
        events: events,
        predictor_events: predictor_events,
        user_pageviews: user_pageviews[:results],
        user_predictor_pageviews: user_predictor_pageviews[:results],
        user_logins: user_logins[:results],
        users: users,
        assignments: assignments
      }

      [
        CourseEventExport,
        CoursePredictorExport,
        CourseUserAggregateExport
      ].each do |export_model|
        export_model.new(data).generate_csv export_dir
      end

      # create a place to store our final archive, for now
      output_dir = Dir.mktmpdir nil, s3fs_prefix

      # expand the export filename against our temporary directory path
      export_filepath = File.join(output_dir, export.export_filename)

      begin
        # generate the actual zip file here
        Archive::Zip.archive(export_filepath, export_dir)

      ensure
        # we're not sending the file to the controller anymore, so let's
        # just upload it to s3
        export.upload_file_to_s3 export_filepath

        export.update_attributes last_completed_step: "build_the_export"
      end
    ensure
      # get rid of any tempfiles we were using as well
      FileUtils.remove_entry_secure export_dir, output_dir
    end
  end
end
