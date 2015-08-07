json.assignment_types @assignment_types do |assignment_type|
  cache ["v1", assignment_type] do
    json.merge! assignment_type.attributes
    json.max_value assignment_type.max_value
  end
end

json.term_for_assignment_type term_for :assignment_type

