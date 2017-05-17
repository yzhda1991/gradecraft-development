json.data @courses do |course|
  json.type                                   "lms_course"
  json.id                                     course["id"]

  json.attributes do
    json.id                                   course["id"]
    json.name                                 course["name"]
    json.description                          course["syllabus_body"]
  end
end
