class SubmissionsExport < ActiveRecord::Base
  # treat this resource as if it's responsible for managing an object on s3
  # Note that if this record is an ActiveRecord::Base descendant then a
  # callback for :rebuild_s3_object_key is added for on: :save
  #
  include S3Manager::Resource

  # give this resource additional methods that aren't s3-specific but that
  # assist in the export process
  #
  include Export::Model

  attr_accessible :course_id, :professor_id, :team_id, :assignment_id,
    :submissions_snapshot, :s3_object_key, :export_filename, :s3_bucket,
    :last_export_started_at, :last_export_completed_at, :student_ids,
    :performer_error_log, :last_completed_step

  belongs_to :course
  belongs_to :professor, class_name: "User", foreign_key: "professor_id"
  belongs_to :team
  belongs_to :assignment

  # secure tokens allow for one-click downloads of the file from an email
  has_many :secure_tokens, as: :target, dependent: :destroy

  validates :course_id, presence: true
  validates :assignment_id, presence: true

  # tell s3 which directory structure to use for exports
  def s3_object_key_prefix
    "exports/courses/#{course_id}/assignments/#{assignment_id}/" \
      "#{object_key_date}/#{object_key_microseconds}"
  end

  def url_safe_filename
    complete_filename = "#{export_file_basename}.zip"
    Formatter::Filename.new(complete_filename).url_safe.filename
  end

  # methods for building and formatting the archive filename
  def export_file_basename
    @export_file_basename ||= "#{archive_basename} - #{filename_timestamp}".gsub("\s+"," ")
  end

  def filename_timestamp
    filename_time.strftime("%Y-%m-%d - %l%M%p").gsub("\s+"," ")
  end

  def archive_basename
    [formatted_assignment_name, formatted_team_name].compact.join " - "
  end

  def formatted_assignment_name
    @formatted_assignment_name ||= Formatter::Filename.titleize assignment.name
  end

  def formatted_team_name
    @team_name ||= Formatter::Filename.titleize(team.name) if has_team?
  end

  def has_team?
    team_id.present?
  end
end
