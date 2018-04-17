json.data do
  json.array! @groups do |group|
    json.type "groups"
    json.id group.id

    json.attributes do
      json.id group.id
      json.name group.name
    end
  end
end

json.included do
  json.array! @group_grades do |grade|
    json.type "grades"
    json.id grade.id

    json.raw_points grade.raw_points
    json.pass_fail_status grade.pass_fail_status
    json.graded grade.persisted?
  end
end

json.meta do
  json.term_for_groups term_for :groups
end
