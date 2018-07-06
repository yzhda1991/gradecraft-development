class BadgeIconUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  process resize_and_pad: [150, 150, background = :transparent, gravity = "Center"]

  def default_url
    ActionController::Base.helpers.asset_path("badge.png")
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
