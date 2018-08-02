class ChallengeFile < ApplicationRecord
  include S3Manager::Carrierwave

  belongs_to :challenge, inverse_of: :challenge_files

  validates :filename, presence: true, length: { maximum: 50 }

  mount_uploader :file, AttachmentUploader
  process_in_background :file
end
