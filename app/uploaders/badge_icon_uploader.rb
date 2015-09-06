class BadgeIconUploader < ImageUploader
  def default_url
    "/images/" + [version_name, "badge.png"].compact.join('_')
  end
end
