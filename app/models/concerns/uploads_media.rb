module UploadsMedia
  extend ActiveSupport::Concern

  included do
    attr_accessible :media, :media_credit, :media_caption, :remove_media

    mount_uploader :media, ImageUploader

    validates :media, file_size: { maximum: 2.megabytes.to_i }
  end
end
