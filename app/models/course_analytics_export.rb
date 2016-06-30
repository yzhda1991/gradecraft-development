class CourseAnalyticsExport < ActiveRecord::Base
  # treat this resource as if it's responsible for managing an object on s3
  include S3Manager::Resource

  belongs_to :course
  belongs_to :professor, class_name: "User", foreign_key: "professor_id"

  has_many :secure_tokens, as: :target, dependent: :destroy

  attr_accessible :course_id, :professor_id,
    :last_export_started_at, :last_export_completed_at, :last_completed_step

  validates :course_id, presence: true

  before_save :rebuild_s3_object_key, if: :export_filename_changed?


  def s3_object_key_prefix
    [
      "exports",
      "courses",
      course_id,
      "assignments",
      assignment_id,
      created_at_date,
      created_at_in_microseconds
    ].join "/"
  end
end
