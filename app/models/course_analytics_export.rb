require "s3_manager"
require "export"
require "formatter"

class CourseAnalyticsExport < ActiveRecord::Base
  # treat this resource as if it's responsible for managing an object on s3.
  # If this is an active_record descendent than add some callbacks.
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
  validates :professor_id, presence: true

  # this should be moved into the Exports::Model module, or a new
  # SecureToken::Target module, but since SecureToken still lives in /app/models
  # it feels weird to have to include an app resource to test /lib
  #
  def generate_secure_token
    SecureToken.create user_id: professor.id, course_id: course.id, target: self
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
    course_number = course.courseno.gsub(/\/+/,"-").gsub("&", "and")

    # then run it through our global url-safe filename formatter
    Formatter::Filename.new(course_number).url_safe.filename
  end

  # this is going to be the downloaded filename of the final archive
  #
  def url_safe_filename
    "#{formatted_course_number}_analytics_export_#{filename_timestamp}.zip"
  end
end
