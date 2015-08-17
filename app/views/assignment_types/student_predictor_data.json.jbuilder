json.assignment_types @assignment_types do |assignment_type|
  cache ["v1", assignment_type] do
    json.merge! assignment_type.attributes
    json.max_value assignment_type.max_value
    if assignment_type.student_weightable?
      json.student_weight  @student.weight_for_assignment_type(assignment_type)
    end
  end
end

json.term_for_assignment_type term_for :assignment_type
