class ThumbnailUploader < ImageUploader
  process resize_and_pad: [25, 25, background = "transparent", gravity = "Center"]
end
