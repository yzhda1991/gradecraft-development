json.assignment_types @assignment_types do |assignment_type|
  json.merge! assignment_type.attributes
  json.max_value assignment_type.max_value
end

json.term_for_assignment_type term_for :assignment_type

