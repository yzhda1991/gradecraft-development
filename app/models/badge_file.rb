class BadgeFile < ApplicationRecord
  include S3Manager::Carrierwave

  belongs_to :badge, inverse_of: :badge_files

  mount_uploader :file, AttachmentUploader

  validates_presence_of :file
  validates :filename, presence: true, length: { maximum: 50 }

  def course
    badge.course
  end
end
