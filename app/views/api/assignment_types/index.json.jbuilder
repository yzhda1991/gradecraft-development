json.data @assignment_types do |assignment_type|
  json.partial! 'api/assignment_types/assignment_type', assignment_type: assignment_type, student: @student
end

json.meta do
  json.term_for_assignment_type term_for :assignment_type
  json.term_for_weights term_for :weights
  json.update_weights @update_weights

  json.total_weights current_course.try(:total_weights)
  json.weights_close_at current_course.try(:weights_close_at)
  json.max_weights_per_assignment_type current_course.max_weights_per_assignment_type
  json.max_assignment_types_weighted current_course.max_assignment_types_weighted
end
