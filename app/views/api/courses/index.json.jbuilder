json.data @courses do |course|
  if current_user_is_admin?
    json.partial! 'api/courses/course', course: course
  else
    json.type "courses"
    json.id course.id.to_s

    json.attributes do
      json.partial! "api/courses/course_search", course: course
    end
  end
end

json.included do

end

json.meta do

end
