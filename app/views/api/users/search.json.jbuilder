json.data do
  json.array! @users do |user|
    json.type "user"
    json.id   user.id.to_s

    json.relationships do
      json.data do
        json.array! user.course_memberships do |cm|
          json.type "course_membership"
          json.id cm.id.to_s
        end
      end
    end

    json.attributes do
      json.id                         user.id.to_s
      json.first_name                 user.first_name
      json.last_name                  user.last_name
    end

    json.included do
      json.array! user.course_memberships do |cm|
        json.type                     "course_membership"
        json.id                       cm.id.to_s
        json.course_name              cm.course.name
        json.role                     cm.role
        if cm.role == "student"
          json.score                    cm.score.to_s
        end
      end
    end
  end
end
