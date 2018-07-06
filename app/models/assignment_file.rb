class AssignmentFile < ApplicationRecord
  include S3Manager::Carrierwave

  belongs_to :assignment, inverse_of: :assignment_files

  validates :filename, presence: true, length: { maximum: 50 }

  mount_uploader :file, AttachmentUploader

  def course
    assignment.course
  end
end
