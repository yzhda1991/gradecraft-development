# @mz todo: add specs
class AssignmentExport < ActiveRecord::Base
  belongs_to :course
  belongs_to :professor, class_name: "User", foreign_key: "professor_id"
  belongs_to :team
  belongs_to :assignment

  include ExportHelpers::S3

  attr_accessible :course_id, :professor_id, :team_id, :assignment_id, :submissions_snapshot,
    :s3_object_key, :export_filename

  def s3_object_key_path
    "/exports/courses/#{course_id}/assignments/#{assignment_id}"
  end

  def s3_object_key
    "#{s3_object_key_path}/#{export_filename}"
  end

end
