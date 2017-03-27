json.data do
  json.array! @users do |user|
    json.type "user"
    json.id   user.id.to_s

    json.attributes do
      json.id                         user.id.to_s
      json.first_name                 user.first_name
      json.last_name                  user.last_name
    end
  end
end
