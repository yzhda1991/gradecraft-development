json.data @unlock_conditions do |unlock_condition|
  json.partial! 'api/unlock_conditions/unlock_condition', unlock_condition: unlock_condition
end

json.meta do
  json.assignments current_course.assignments.alphabetical.each do |assignment|
    json.id assignment.id.to_s
    json.name assignment.name
    json.pass_fail assignment.pass_fail
  end

  json.assignment_types current_course.assignment_types.each do |assignment_type|
    json.id assignment_type.id
    json.name assignment_type.name
  end

  json.badges current_course.badges.each do |badge|
    json.id badge.id
    json.name badge.name
  end

  json.course_id current_course.id
end
