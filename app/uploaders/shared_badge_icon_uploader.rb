class SharedBadgeIconUploader < CarrierWave::Uploader::Base
  def store_dir
    "uploads/badge/#{mounted_as}/#{model.badge_id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
