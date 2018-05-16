json.type "courses"
json.id course.id.to_s

json.attributes do
  json.partial! "api/courses/course_search", course: course
end

json.relationships do

end
