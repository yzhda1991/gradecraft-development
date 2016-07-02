# This class serves expressly to assemble the various components that we need
# in our export at all.
#
# Because we've already defined the data filtering mechanisms in each export
# class, we really just need the names of the classes to run the data against.
#
# And because we might want to use different sets of data to run against the
# export classes, we also have an export context that encapsulates all of the
# data that we're going to use in the export process.
#
class CourseExportOrganizer < Analytics::Export::Organizer
  attr_reader :course

  def initialize(course:)
    @course = course
  end

  def export_classes
    [CourseEventExport, CoursePredictorExport, CourseUserAggregateExport]
  end

  def context
    # this is literally just the entire data-fetching process as pulled from
    # AnalyticsController#export. This is pretty messy, but let's deal with
    # it later so we don't have to refactor everything right now.
    #
    @context ||= CourseExportContext.new course: course
  end

  # this is the name of the directory in the root of the final archive
  #
  def directory_name
    formatted_course_number
  end

  # this is the filename of the final exported file that we're going to produce
  #
  def filename
    "#{ formatted_course_number }_anayltics_export_" \
    "#{ Time.now.strftime('%Y-%m-%d') }.zip"
  end

  def formatted_course_number
    # create a url-safe course number for the export's root directory
    # be sure to replace forward-slashes with hyphens and ampersands
    # with the word 'and'
    #
    @formatted_course_number ||= Formatter::Filename.new(
      course.courseno.gsub(/\/+/,"-").gsub("&", "and")
    ).url_safe.filename
  end
end
