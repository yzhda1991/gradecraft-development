json.errors do
  json.array! @submission.errors.full_messages do |message|
    json.detail message
  end
end
