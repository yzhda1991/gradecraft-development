json.data @unlock_conditions do |uc|
  json.type "unlock_condition"
  json.id uc.id.to_s

  json.attributes do
    json.merge! uc.attributes
  end
end

json.meta do
  json.assignments current_course.assignments.alphabetical.each do |assignment|
    json.id assignment.id.to_s
    json.name assignment.name
    json.pass_fail assignment.pass_fail
  end

  json.assignment_type current_course.assignment_types.each do |assignment_type|
    json.id assignment_type.id
    json.name assignment_type.name
  end

  json.badges current_course.badges.each do |badge|
    json.id badge.id
    json.name badge.name
  end
end
