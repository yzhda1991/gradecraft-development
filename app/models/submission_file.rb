class SubmissionFile < ApplicationRecord
  include S3Manager::Carrierwave
  include S3Manager::Streaming
  include Historical

  belongs_to :submission, inverse_of: :submission_files

  mount_uploader :file, AttachmentUploader
  process_in_background :file
  has_paper_trail ignore: [:file_missing, :last_confirmed_at]

  validates :filename, presence: true, length: { maximum: 50 }
  validates :file, file_size: { maximum: 40.megabytes.to_i }

  scope :unconfirmed, -> { where("last_confirmed_at is null") }
  scope :confirmed, -> { where("last_confirmed_at is not null") }
  scope :missing, -> { where(file_missing: true) }
  scope :present, -> { where(file_missing: false) }

  def s3_manager
    @s3_manager ||= S3Manager::Manager.new
  end

  def mark_file_missing
    update_attributes file_missing: true, last_confirmed_at: Time.now
  end

  def check_and_set_confirmed_status
    update_attributes file_missing: file_missing?, last_confirmed_at: Time.now
  end

  def file_missing?
    !exists_on_storage?
  end

  def exists_on_storage?
    S3Manager::Manager::ObjectSummary.new(s3_object_file_key, s3_manager).exists?
  end

  def course
    submission.course
  end

  def assignment
    submission.assignment
  end

  def instructor_filename(index=nil)
    file_number = index.class == Fixnum ? " #{index + 1}" : ""
    "#{submission.base_filename} - Submission File#{file_number}#{extension}"
  end

  # returns nil if group or student has been deleted but file still exists
  def owner_name
    if submission.assignment.grade_scope == "Group"  && submission.group.present?
      submission.group.name.gsub(/\s/, "-")
    elsif submission.assignment.grade_scope == "Individual" && submission.student.present?
      "#{submission.student.last_name}-#{submission.student.first_name}"
    end
  end

  def extension
    File.extname(filename)
  end
end
