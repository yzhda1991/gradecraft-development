json.assignment_types @assignment_types do |assignment_type|
  #json.extract! assignment, :id, :name
  json.merge! assignment_type.attributes
end

