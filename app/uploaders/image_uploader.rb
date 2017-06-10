class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  process resize_and_pad: [250, 150, background = :transparent, gravity = "Center"]

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
