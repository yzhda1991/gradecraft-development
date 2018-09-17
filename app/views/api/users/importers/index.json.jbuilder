json.data @result[:users] do |user|
  gradecraft_user = User.find_by_insensitive_email(user["email"])
  user_exists = lms_user_match?(user["email"], nil, current_course)
  gradecraft_role = lms_user_role(user["enrollments"])

  json.type                                   "imported_user"
  json.id                                     user["id"]

  json.attributes do
    json.id                                   user["id"]
    json.name                                 user["name"]
    json.email                                user["email"]
    json.enrollments                          user["enrollments"]
    json.gradecraft_role                      gradecraft_role
    json.user_exists                          user_exists
    json.current_role                         gradecraft_user.role(current_course) \
                                                if user_exists
    json.role_changed                         gradecraft_role != gradecraft_user.role(current_course) \
                                                if user_exists
  end
end

json.meta do
  json.page_params @result[:page_params]
end
