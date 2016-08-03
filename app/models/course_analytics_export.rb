require "s3_manager"
require "export"
require "formatter"
require "analytics/export"

class CourseAnalyticsExport < ActiveRecord::Base
  # treat this resource as if it's responsible for managing an object on s3.
  # If this is an active_record descendent than add some callbacks.
  #
  include S3Manager::Resource

  # give this resource additional methods that aren't s3-specific but that
  # assist in the export process
  #
  include Export::Model

  attr_accessible :last_export_started_at, :last_export_completed_at,
    :last_completed_step

  belongs_to :course
  belongs_to :owner, class_name: "User", foreign_key: "owner_id"

  # secure tokens allow for one-click downloads of the file from an email
  has_many :secure_tokens, as: :target, dependent: :destroy

  validates :course_id, presence: true
  validates :owner_id, presence: true

  # this should be moved into the Exports::Model module, or a new
  # SecureToken::Target module, but since SecureToken still lives in /app/models
  # it feels weird to have to include an app resource to test /lib
  #
  def generate_secure_token
    SecureToken.create user_id: owner.id, course_id: course.id, target: self
  end

  # classes that we're going to include in the export
  def export_classes
    [CourseEventExport, CoursePredictorExport, CourseUserAggregateExport]
  end

  def build_archive!
    export_builder.build_archive!
  end

  def upload_builder_archive_to_s3
    upload_file_to_s3 export_builder.final_export_filepath
  end

  def export_builder
    @export_builder ||= Analytics::Export::Builder.new \
      export_data: export_context.export_data,
      export_classes: export_classes,
      filename: url_safe_filename,
      directory_name: formatted_course_number # root directory name
  end

  # the export context contains all of the data we need to build the
  def export_context
    @export_context ||= CourseExportContext.new course: course
  end

  # tell s3 which directory structure to use for exports. the object_key
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
    course_number = course.course_number.gsub(/\/+/,"-").gsub("&", "and")

    # then run it through our global url-safe filename formatter
    Formatter::Filename.new(course_number).url_safe.filename
  end

  # this is going to be the downloaded filename of the final archive
  #
  def url_safe_filename
    "#{formatted_course_number} Analytics Export - #{filename_timestamp}.zip"
  end
end
