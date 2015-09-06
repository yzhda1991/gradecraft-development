module UploadsThumbnails
  extend ActiveSupport::Concern

  included do
    attr_accessible :thumbnail, :remove_thumbnail

    mount_uploader :thumbnail, ThumbnailUploader

    validates :thumbnail, file_size: { maximum: 2.megabytes.to_i }
  end
end
