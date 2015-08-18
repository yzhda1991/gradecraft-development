json.weights do
  assignment_types_weightable = []
  @assignment_types.each do |assignment_type|
    if assignment_type.student_weightable?
      assignment_types_weightable << assignment_type.id
    end
  end
  json.assignment_types_weightable assignment_types_weightable

  json.total_weights current_course.try(:total_assignment_weight)
  json.close_at current_course.try(:assignment_weight_close_at)
  json.max_weights current_course.max_assignment_weight
  json.max_types_weighted current_course.max_assignment_types_weighted
  json.default_weight current_course.default_assignment_weight
end

json.term_for_weights term_for :weights
