require "s3_manager"
require "export"

class CourseAnalyticsExport < ActiveRecord::Base
  # treat this resource as if it's responsible for managing an object on s3
  # Note that if this record is an ActiveRecord::Base descendant then a
  # callback for :rebuild_s3_object_key is added for on: :save
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

  # if we destroy the export successfully clean the data off of S3
  after_destroy :delete_object_from_s3

  # let's save the name of the export so we don't have to do it later
  before_create :cache_export_filename

  before_save :rebuild_s3_object_key, if: :export_filename_changed?

  # tell s3 which directory structure to use for exports. the created_at_*
  # methods here are included from Export::Model
  #
  def s3_object_key_prefix
    "exports/courses/#{course_id}/course_analytics_exports/" \
      "#{created_at_date}/#{created_at_in_microseconds}"
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
    filename_time = created_at || Time.now

    # this is going to be the downloaded filename of the final archive
    "#{ formatted_course_number }_anayltics_export_" \
    "#{ filename_time.strftime('%Y-%m-%d') }.zip"
  end

  protected

  def cache_export_filename
    self.export_filename = url_safe_filename
  end
end
