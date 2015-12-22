class SubmissionFile < ActiveRecord::Base
  include S3File

  attr_accessible :file, :filename, :filepath, :submission_id

  belongs_to :submission

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  validates :filename, presence: true, length: { maximum: 50 }
  validates :file, file_size: { maximum: 40.megabytes.to_i }

  def course
    submission.course
  end

  def assignment
    submission.assignment
  end

  def student
    submission.student
  end
end
