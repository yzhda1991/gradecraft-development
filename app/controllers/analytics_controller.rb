class AnalyticsController < ApplicationController
  before_filter :ensure_staff?
  before_filter :set_granularity_and_range

  def index
    @title = "User Analytics"
  end

  def students
    @title = "#{term_for :student} Analytics"
  end

  def staff
    @title = "#{term_for :team_leader} Analytics"
  end

  def all_events
    data = CourseEvent.data(@granularity, @range,
      { course_id: current_course.id }, { event_type: "_all" })

    render json: MultiJson.dump(data)
  end

  def role_events
    data = CourseRoleEvent.data(@granularity, @range, {
      course_id: current_course.id, role_group: params[:role_group]
      }, { event_type: "_all" })

    render json: MultiJson.dump(data)
  end

  def assignment_events
    assignments = Hash[current_course.assignments.select([:id, :name]).collect{
      |h| [h.id, h.name]
      }]
    data = AssignmentEvent.data(@granularity, @range,
      {assignment_id: assignments.keys},
      {event_type: "_all"})

    data.decorate! {
      |result| result[:name] = assignments[result.assignment_id]
    }

    render json: MultiJson.dump(data)
  end

  def login_frequencies
    data = CourseLogin.data(@granularity, @range, {
      course_id: current_course.id
      })

    data[:lookup_keys] = ["{{t}}.average"]

    data.decorate! do |result|
      result[:name] = "Average #{data[:granularity]} login frequency"
      # Get frequency
      result[data[:granularity]].each do |key, values|
        result[data[:granularity]][key][:average] =
          (values["total"] / values["count"]).round(2)
      end
    end

    render json: MultiJson.dump(data)
  end

  def role_login_frequencies
    data = CourseRoleLogin.data(@granularity, @range,
      {course_id: current_course.id, role_group: params[:role_group]})

    data[:lookup_keys] = ["{{t}}.average"]

    data.decorate! do |result|
      result[:name] = "Average #{data[:granularity]} login frequency"
      # Get frequency
      result[data[:granularity]].each do |key, values|
        result[data[:granularity]][key][:average] = (values["total"] /
          values["count"]).round(2)
      end
    end

    render json: MultiJson.dump(data)
  end

  def login_events
    data = CourseLogin.data(@granularity, @range, {
      course_id: current_course.id
      })

    # Only graph counts
    data[:lookup_keys] = ["{{t}}.count"]

    render json: MultiJson.dump(data)
  end

  def login_role_events
    data = CourseRoleLogin.data(@granularity, @range,
      {course_id: current_course.id, role_group: params[:role_group]})

    # Only graph counts
    data[:lookup_keys] = ["{{t}}.count"]

    render json: MultiJson.dump(data)
  end

  def all_pageview_events
    data = CoursePageview.data(@granularity, @range,
      {course_id: current_course.id}, {page: "_all"})

    render json: MultiJson.dump(data)
  end

  def all_role_pageview_events
    data = CourseRolePageview.data(@granularity, @range,
      {course_id: current_course.id, role_group: params[:role_group]},
      {page: "_all"})

    render json: MultiJson.dump(data)
  end

  def all_user_pageview_events
    user = current_course.students.find(params[:user_id])
    data = CourseUserPageview.data(@granularity, @range,
      {course_id: current_course.id, user_id: user.id},
      {page: "_all"})

    render json: MultiJson.dump(data)
  end

  def pageview_events
    data = CoursePagePageview.data(@granularity, @range,
      {course_id: current_course.id})
    data.decorate! { |result| result[:name] = result.page }

    render json: MultiJson.dump(data)
  end

  def role_pageview_events
    data = CourseRolePagePageview.data(@granularity, @range,
      {course_id: current_course.id, role_group: params[:role_group]})
    data.decorate! { |result| result[:name] = result.page }

    render json: MultiJson.dump(data)
  end

  def user_pageview_events
    user = current_course.students.find(params[:user_id])
    data = CourseUserPagePageview.data(@granularity, @range,
      {course_id: current_course.id, user_id: user.id})
    data.decorate! { |result| result[:name] = result.page }

    render json: MultiJson.dump(data)
  end

  def prediction_averages
    data = CoursePrediction.data(@granularity, @range,
      {course_id: current_course.id})

    data[:lookup_keys] = ["{{t}}.average"]
    data.decorate! do |result|
      result[data[:granularity]].each do |key, values|
        result[data[:granularity]][key][:average] =
          (values["total"] / values["count"] * 100).to_i
      end
    end

    render json: MultiJson.dump(data)
  end

  def assignment_prediction_averages
    assignments = Hash[current_course.assignments.select([:id, :name]).collect{
      |h| [h.id, h.name]
      }]
    data = AssignmentPrediction.data(@granularity, @range, {
      assignment_id: assignments.keys
      })

    data[:lookup_keys] = ["{{t}}.count", "{{t}}.total"]
    data.decorate! do |result|
      result[:name] = assignments[result.assignment_id]
    end

    render json: MultiJson.dump(data)
  end

  # TODO: fix this
  def export
    respond_to do |format|
      # please note that this is all going to be refactored in the subsequent
      # pull request, so I'm doing my best to just get this into working condition
      # for use on @cait's dissertation.
      #
      # All of this will be moved into a dedicated CourseAnalyticsExport class which
      # will handle this entire process in order to move all of the export logic
      # out of the controller.
      #
      format.zip do
        # check whether we need to use S3fs
        use_s3fs = %w[staging production].include? Rails.env

        # if we do use the prefix for the s3fs tempfiles
        s3fs_prefix = use_s3fs ? "/s3mnt/tmp/#{Rails.env}" : nil

        # create a working tmpdir for the export
        export_tmpdir = Dir.mktmpdir nil, s3fs_prefix

        # create a url-safe course number for the export's root directory
        # be sure to replace forward-slashes with hyphens and ampersands
        # with the word 'and'
        #
        course_number = Formatter::Filename.new(
          current_course.course_number.gsub(/\/+/,"-").gsub("&", "and")
        ).url_safe.filename

        # create a named directory to generate the files in
        export_dir = FileUtils.mkdir \
          File.join(export_tmpdir, course_number)

        id = current_course.id

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
          ].each do |export|
            export.new(data).generate_csv export_dir
          end

          # this is going to be the downloaded filename of the final archive
          export_filename = "#{ course_number }_anayltics_export_" \
                            "#{ Time.now.strftime('%Y-%m-%d') }.zip"

          # create a place to store our final archive, for now
          output_dir = Dir.mktmpdir nil, s3fs_prefix

          # expand the export filename against our temporary directory path
          export_filepath = File.join(output_dir, export_filename)

          # generate the actual zip file here
          Archive::Zip.archive(export_filepath, export_dir)

          # and render it for the user
          send_file export_filepath
        ensure
          # get rid of any tempfiles we were using as well
          FileUtils.remove_entry_secure export_dir, output_dir
        end
      end
    end
  end

  private

  def set_granularity_and_range
    @granularity = :daily

    if current_course.start_date && current_course.end_date
      @range = (current_course.start_date..current_course.end_date)
    else
      @range = :past_year
    end
  end
end
