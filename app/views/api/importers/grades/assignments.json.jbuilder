json.data @assignments do |assignment|
  json.type                                   "lms_assignment"
  json.id                                     assignment["id"]

  json.attributes do
    json.id                                   assignment["id"]
    json.name                                 assignment["name"]
    json.description                          assignment["description"] || ""
    json.due_at                               assignment["due_at"]
    json.points_possible                      assignment["points_possible"]
  end
end
