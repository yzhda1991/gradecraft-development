json.data do
  json.array! @users do |user|
    json.type "user"
    json.id   user.id.to_s

    json.attributes do
      json.id                         user.id.to_s
      json.first_name                 user.first_name
      json.last_name                  user.last_name
      json.course_memberships user.course_memberships.map {
        |cm| { course_id: cm.course.id,
               course_name: cm.course.name,
               role: term_for(cm.role, cm.role.capitalize),
               score: cm.role == "student" ? cm.score : nil }.compact
      }
    end
  end
end
