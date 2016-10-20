json.errors do
  json.array! @prediction.errors.full_messages do |message|
    json.detail message
  end
end
