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

  # tell s3 which directory structure to use for exports. the created_at_*
  # methods here are included from Export::Model
  #
  def s3_object_key_prefix
    "exports/courses/#{course_id}/course_analytics_exports/" \
      "#{created_at_date}/#{created_at_in_microseconds}"
  end
end
