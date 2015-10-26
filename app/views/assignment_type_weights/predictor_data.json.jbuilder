json.weights do
  json.assignment_types_weightable @assignment_types_weightable
  json.total_weights @total_weights
  json.close_at @close_at
  json.max_weights @max_weights
  json.max_types_weighted @max_types_weighted
  json.default_weight @default_weight
end

json.update_weights @update_weights

json.term_for_weights term_for :weights
