json.assignment_types @assignment_types do |assignment|
  #json.extract! assignment, :id, :name
  json.merge! assignment.attributes
end

