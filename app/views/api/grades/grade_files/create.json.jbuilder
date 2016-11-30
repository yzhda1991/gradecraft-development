json.data @file_attachments do |file_attachment|
  json.type "file_attachments"
  json.id file_attachment.id.to_s

  json.attributes do
    json.merge! file_attachment.attributes
  end
end
