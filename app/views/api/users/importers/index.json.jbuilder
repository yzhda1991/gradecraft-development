json.data @users[:data] do |user|
  json.type                                   "imported_user"
  json.id                                     user["id"].to_s

  json.attributes do
    json.id                                   user["id"].to_s
    json.name                                 user["name"]
    json.email                                user["email"]
    json.enrollments                          user["enrollments"]
    json.user_exists                          lms_user_match?(user["email"], current_course)
  end
end

json.meta do
  json.has_next_page                          @users[:has_next_page]
end
