require "s3_manager"
require "export"

class CourseAnalyticsExport < ActiveRecord::Base
  # treat this resource as if it's responsible for managing an object on s3
  # Note that if this record is an ActiveRecord::Base descendant then a
  # callback for :rebuild_s3_object_key is added for on: :save
  #
  # Let's define all of the callbacks here, actually, so we don't have to do it
  # on every export model.
  #
  include S3Manager::Resource

  # give this resource additional methods that aren't s3-specific but that
  # assist in the export process
  #
  include Export::Model

  attr_accessible :course_id, :professor_id, :last_export_started_at,
                  :last_export_completed_at, :last_completed_step

  belongs_to :course
  belongs_to :professor, class_name: "User", foreign_key: "professor_id"

  # secure tokens allow for one-click downloads of the file from an email
  has_many :secure_tokens, as: :target, dependent: :destroy

  validates :course_id, presence: true

  # tell s3 which directory structure to use for exports. the created_at_*
  # methods here are included from Export::Model
  #
  def s3_object_key_prefix
    "exports/courses/#{course_id}/course_analytics_exports/" \
      "#{object_key_date}/#{object_key_microseconds}"
  end

  def formatted_course_number
    # create a url-safe course number to use for the export filename and for
    # the root directory of the final export archive. be sure to replace
    # forward-slashes with hyphens and replace ampersands with "and"
    #
    course_number = course.courseno.gsub(/\/+/,"-").gsub("&", "and")

    # then run it through our global url-safe filename formatter
    Formatter::Filename.new(course_number).url_safe.filename
  end

  def url_safe_filename
    # if we need to generate a new filename for some reason, use the created_at
    # date, otherwise let's presume this is a new export and just use Time.now
    # for parsing a date in the format YYYY-MM-DD

    # this is going to be the downloaded filename of the final archive
    "#{ formatted_course_number }_anayltics_export_" \
    "#{ filename_time.strftime('%Y-%m-%d') }.zip"
  end

end
