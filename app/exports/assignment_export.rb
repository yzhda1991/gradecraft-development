# @mz todo: add specs
class AssignmentExport < ActiveRecord::Base
  belongs_to :course
  belongs_to :professor, class_name: "User", foreign_key: "professor_id"
  belongs_to :team
  belongs_to :assignment

  attr_accessible :course_id, :professor_id, :team_id, :assignment_id, :submissions_snapshot,
    :s3_object_key, :export_filename, :s3_bucket, :last_export_started_at, :last_export_completed_at

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
    update_attributes last_export_completed_at: Time.now
  end

  def self.create_with_s3_attributes(creation_attributes)
    new_assignment_export = self.new(creation_attributes)
    new_assignment_export.set_s3_attributes
    new_assignment_export.save
    new_assignment_export
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

  def s3_attributes
    {
      s3_object_key: s3_object_key,
      s3_bucket: s3_manager.bucket
    }
  end
end
