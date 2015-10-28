require_relative "image_uploader"

class BadgeIconUploader < ImageUploader
  def default_url
    "/images/" + [version_name, "badge.png"].compact.join('_')
  end
end
