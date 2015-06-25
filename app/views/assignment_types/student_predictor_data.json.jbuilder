json.assignment_types @assignment_types do |assignment_type|
  #json.extract! assignment, :id, :name
  json.assignments assignment_type.assignments
  json.merge! assignment_type.attributes
end

