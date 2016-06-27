# this is a temporary wrapper class for pulling the analytics export process out
# of AnalyticsController#export so we can perform the process through a Resque
# job to avoid the Timeout issue we're experiencing with running huge exports
# through the controller in Production.
#
# The goal here is just to get this modular enough that we can call with one or
# two lines of code in the job without having to copy the entire 80-line method
# into the job wholesale.
#
class CourseAnalyticsExport
  attr_accessor :complete

  attr_reader :course, :output_dir, :export_filepath

  def initialize(course:)
    @course = course
  end

  def included_export_classes
    [
      CourseEventExport,
      CoursePredictorExport,
      CourseUserAggregateExport
    ]
  end

  def generate!
    generate_csvs
    build_zip_archive
  end

  def export_context
    # this is literally just the entire data-fetching process as pulled from
    # AnalyticsController#export. This is pretty messy, but let's deal with
    # it later so we don't have to refactor everything right now.
    #
    @export_context ||= CourseExportContext.new course: course
  end

  def export_dir
    # return the export dir if we've already built it
    return @export_dir if @export_dir

    # create a working tmpdir for the export
    export_tmpdir = Dir.mktmpdir nil, s3fs_prefix

    # create a named directory to generate the files in
    @export_dir = FileUtils.mkdir File.join(export_tmpdir, current_course.courseno)
  end

  def generate_csvs
    included_export_classes.each do |export_class|
      export_class.new(export_context.export_data).generate_csv export_dir
    end
  end

  def build_zip_archive
    # this is going to be the downloaded filename of the final archive
    export_filename = "#{ current_course.courseno }_anayltics_export_#{ Time.now.strftime('%Y-%m-%d') }.zip"

    # create a place to store our final archive, for now. Let's set the value as
    # an attribute so we can delete it later.
    #
    @output_dir = Dir.mktmpdir nil, s3fs_prefix

    # expand the export filename against our temporary directory path
    @export_filepath = File.join(output_dir, export_filename)

    begin
      # generate the actual zip file here
      Archive::Zip.archive(@export_filepath, export_dir)
    ensure
      @complete = true

      # return the filepath once we're done generating the archive
      @export_filepath
    end
  end

  def use_s3fs?
    # check whether we need to use S3fs
    %w[staging production].include? Rails.env
  end

  def s3fs_prefix
    # if we do use the prefix for the s3fs tempfiles
    use_s3fs? ? "/s3mnt/tmp/#{Rails.env}" : nil
  end

  def remove_tempdirs
    FileUtils.remove_entry_secure export_dir, output_dir
  end
end
