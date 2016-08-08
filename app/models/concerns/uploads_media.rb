module UploadsMedia
  extend ActiveSupport::Concern

  included do
    mount_uploader :media, ImageUploader

    validates :media, file_size: { maximum: 2.megabytes.to_i }
  end
end
