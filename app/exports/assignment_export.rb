# @mz todo: add specs
class AssignmentExport < ActiveRecord::Base
  belongs_to :course
  belongs_to :professor, class_name: "User", foreign_key: "professor_id"
  belongs_to :team
  belongs_to :assignment

  attr_accessible :course_id, :professor_id, :team_id, :assignment_id, :submissions_snapshot,
    :s3_object_key, :export_filename, :s3_bucket, :last_export_started_at, :last_export_completed_at,
    :student_ids, :performer_error_log

  before_create :set_s3_attributes

  def s3_object_key
    "/exports/courses/#{course_id}/assignments/#{assignment_id}/#{export_filename}"
  end

  def s3_manager
    @s3_manager ||= S3Manager::Manager.new
  end

  def upload_file_to_s3(file_path)
    s3_manager.put_encrypted_object(s3_object_key, file_path)
  end

  def update_export_completed_time
    update_attributes last_export_completed_at: export_time
  end

  def set_s3_attributes
    s3_attributes.each do |key, value|
      self[key] = value
    end
  end

  def s3_object_exists?
    s3_object_summary.exists?
  end

  def s3_object_summary
    @s3_object_summary ||= S3Manager::Manager::ObjectSummary.new(s3_object_key, s3_manager)
  end

  private

  def export_time
    Time.now
  end

  def s3_attributes
    {
      s3_object_key: s3_object_key,
      s3_bucket_name: s3_manager.bucket_name
    }
  end
end
