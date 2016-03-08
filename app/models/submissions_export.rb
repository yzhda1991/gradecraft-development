class SubmissionsExport < ActiveRecord::Base
  # treat this resource if it's responsible for managing an object on s3
  include S3Manager::Resource

  belongs_to :course
  belongs_to :professor, class_name: "User", foreign_key: "professor_id"
  belongs_to :team
  belongs_to :assignment

  has_many :secure_tokens, as: :target, dependent: :destroy

  attr_accessible :course_id, :professor_id, :team_id, :assignment_id, :submissions_snapshot,
    :s3_object_key, :export_filename, :s3_bucket, :last_export_started_at, :last_export_completed_at,
    :student_ids, :performer_error_log,
    :generate_export_csv,
    :create_student_directories,
    :student_directories_created_successfully,
    :create_submission_text_files,
    :create_submission_binary_files,
    :remove_empty_student_directories,
    :generate_error_log,
    :archive_exported_files,
    :upload_archive_to_s3,
    :check_s3_upload_success,
    :confirm_export_csv_integrity,
    :write_note_for_missing_binary_files

  validates :course_id, presence: true
  validates :assignment_id, presence: true

  # THESE NEED SPECS
  before_save :rebuild_s3_object_key, if: :export_filename_changed?

  def rebuild_s3_object_key
    # #build_s3_object_key is defined in S3Manager::Resource, and presumes that
    # the resource will have both an accessible s3_object_key attribute as well
    # as an s3_object_key_prefix
    self[:s3_object_key] = build_s3_object_key(export_filename)
  end

  # END THESE NEED SPECS

  def update_export_completed_time
    update_attributes last_export_completed_at: Time.now
  end

  def s3_object_key_prefix
    [
      "exports",
      "courses",
      course_id,
      "assignments",
      assignment_id,
      created_at_date,
      created_at_in_microseconds
    ]
  end

  def created_at_in_microseconds
    created_at.to_f.to_s.gsub(".","")
  end

  def created_at_date
    created_at.strftime("%F")
  end

  def downloadable?
    !!last_export_completed_at
  end
end
